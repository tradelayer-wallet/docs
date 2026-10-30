use std::collections::BTreeMap;
use std::path::Path;
use tl_release_verify::{
    hex, parse_manifest, render_manifest, safe_path, sha256, verify, Entry, Hasher, ManifestError,
    Outcome,
};

const ABC: &str = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";

#[test]
fn sha256_known_answers() {
    assert_eq!(hex(&sha256(b"abc")), ABC);
    assert_eq!(
        hex(&sha256(b"")),
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    );
    let mut h = Hasher::new();
    h.update(b"a");
    h.update(b"bc");
    assert_eq!(hex(&h.finish()), ABC);
}

#[test]
fn parses_gnu_text_and_binary_lines() {
    let m = format!("{ABC}  a.txt\n\n{ABC} *dir/b c.exe\r\n");
    let e = parse_manifest(&m).unwrap();
    assert_eq!(e.len(), 2);
    assert_eq!(e[0].path, "a.txt");
    assert_eq!(e[1].path, "dir/b c.exe");
    assert_eq!(
        render_manifest(&e),
        format!("{ABC} *a.txt\n{ABC} *dir/b c.exe\n")
    );
    assert_eq!(parse_manifest(&render_manifest(&e)).unwrap(), e);
}

#[test]
fn malformed_manifests_are_refused() {
    let up = ABC.to_uppercase();
    let cases = [
        (format!("{ABC} a.txt\n"), ManifestError::Syntax(1)),
        (format!("{}  a.txt\n", &ABC[..63]), ManifestError::Syntax(1)),
        (format!("{up}  a.txt\n"), ManifestError::Syntax(1)),
        (format!("{ABC}  ../a.txt\n"), ManifestError::BadPath(1)),
        (format!("{ABC}  /etc/passwd\n"), ManifestError::BadPath(1)),
        (format!("{ABC}  a/./b\n"), ManifestError::BadPath(1)),
        (format!("{ABC}  a\\b\n"), ManifestError::BadPath(1)),
        (format!("{ABC}  -rf\n"), ManifestError::BadPath(1)),
        (format!("{ABC}  a\n{ABC}  a\n"), ManifestError::Duplicate(2)),
        ("\n\n".to_string(), ManifestError::Empty),
        ("garbage\n".to_string(), ManifestError::Syntax(1)),
    ];
    for (text, err) in cases {
        assert_eq!(parse_manifest(&text), Err(err), "{text:?}");
    }
    assert!(safe_path("TradeLayer-Wallet-Setup-0.1.exe"));
    assert!(!safe_path(""));
    assert!(!safe_path(&"a".repeat(256)));
}

#[test]
fn verify_reports_missing_mismatch_and_unlisted() {
    let e = vec![
        Entry {
            path: "a".into(),
            sha256: sha256(b"abc"),
        },
        Entry {
            path: "b".into(),
            sha256: sha256(b"b"),
        },
        Entry {
            path: "c".into(),
            sha256: sha256(b"c"),
        },
    ];
    let mut present = BTreeMap::new();
    present.insert("a".to_string(), sha256(b"abc"));
    present.insert("b".to_string(), sha256(b"tampered"));
    present.insert("extra.exe".to_string(), sha256(b"x"));
    let r = verify(&e, &present);
    assert_eq!(r.results[0].1, Outcome::Ok);
    assert_eq!(
        r.results[1].1,
        Outcome::Mismatch {
            actual: sha256(b"tampered")
        }
    );
    assert_eq!(r.results[2].1, Outcome::Missing);
    assert_eq!(r.unlisted, ["extra.exe"]);
    assert!(!r.all_ok());
    present.remove("extra.exe");
    present.insert("b".to_string(), sha256(b"b"));
    present.insert("c".to_string(), sha256(b"c"));
    assert!(verify(&e, &present).all_ok());
}

#[test]
fn committed_manifest_matches_the_downloads_in_this_repository() {
    let book = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../_book");
    let text = std::fs::read_to_string(book.join("RELEASES.sha256")).unwrap();
    let entries = parse_manifest(&text).unwrap();
    let mut present = BTreeMap::new();
    for e in &entries {
        // Git LFS pointer files or blob-filtered clones would not match; skip absent.
        if let Ok(bytes) = std::fs::read(book.join(&e.path)) {
            present.insert(e.path.clone(), sha256(&bytes));
        }
    }
    let report = verify(&entries, &present);
    for (path, outcome) in &report.results {
        assert!(
            matches!(outcome, Outcome::Ok | Outcome::Missing),
            "{path}: {outcome:?}"
        );
    }
    assert_eq!(entries.len(), 2);
}
