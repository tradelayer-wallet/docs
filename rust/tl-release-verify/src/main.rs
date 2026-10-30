//! `tl-release-verify check <manifest> <dir> [artifact ...]`
//! `tl-release-verify make <dir> <artifact ...>`
//!
//! `check` hashes the listed artifacts (and any extra artifacts named on the command
//! line, which are reported as unlisted) relative to `<dir>`; exit 0 only if all match.
//! `make` prints a manifest for the named artifacts.
#![forbid(unsafe_code)]

use std::collections::BTreeMap;
use std::fs::File;
use std::io::Read;
use std::path::Path;
use std::process::ExitCode;
use tl_release_verify::{hex, parse_manifest, render_manifest, safe_path, Entry, Hasher, Outcome};

fn hash_file(dir: &Path, rel: &str) -> std::io::Result<[u8; 32]> {
    let mut f = File::open(dir.join(rel))?;
    let mut h = Hasher::new();
    let mut buf = vec![0u8; 1 << 16];
    loop {
        let n = f.read(&mut buf)?;
        if n == 0 {
            break;
        }
        h.update(&buf[..n]);
    }
    Ok(h.finish())
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    match args.first().map(String::as_str) {
        Some("check") if args.len() >= 3 => {
            let text = match std::fs::read_to_string(&args[1]) {
                Ok(t) => t,
                Err(e) => {
                    eprintln!("manifest: {e}");
                    return ExitCode::from(2);
                }
            };
            let entries = match parse_manifest(&text) {
                Ok(e) => e,
                Err(e) => {
                    eprintln!("manifest: {e}");
                    return ExitCode::from(2);
                }
            };
            let dir = Path::new(&args[2]);
            let mut present = BTreeMap::new();
            let names = entries
                .iter()
                .map(|e| e.path.clone())
                .chain(args[3..].iter().cloned());
            for name in names {
                if !safe_path(&name) {
                    eprintln!("refusing unsafe path {name:?}");
                    return ExitCode::from(2);
                }
                if let Ok(d) = hash_file(dir, &name) {
                    present.insert(name, d);
                }
            }
            let report = tl_release_verify::verify(&entries, &present);
            for (path, outcome) in &report.results {
                match outcome {
                    Outcome::Ok => println!("OK        {path}"),
                    Outcome::Missing => println!("MISSING   {path}"),
                    Outcome::Mismatch { actual } => {
                        println!("MISMATCH  {path} (actual {})", hex(actual))
                    }
                }
            }
            for path in &report.unlisted {
                println!("UNLISTED  {path}");
            }
            if report.all_ok() {
                ExitCode::SUCCESS
            } else {
                ExitCode::from(1)
            }
        }
        Some("make") if args.len() >= 3 => {
            let dir = Path::new(&args[1]);
            let mut entries = Vec::new();
            for name in &args[2..] {
                if !safe_path(name) {
                    eprintln!("refusing unsafe path {name:?}");
                    return ExitCode::from(2);
                }
                match hash_file(dir, name) {
                    Ok(sha256) => entries.push(Entry {
                        path: name.clone(),
                        sha256,
                    }),
                    Err(e) => {
                        eprintln!("{name}: {e}");
                        return ExitCode::from(2);
                    }
                }
            }
            print!("{}", render_manifest(&entries));
            ExitCode::SUCCESS
        }
        _ => {
            eprintln!("usage: tl-release-verify check <manifest> <dir> [artifact ...]");
            eprintln!("       tl-release-verify make <dir> <artifact ...>");
            ExitCode::from(2)
        }
    }
}
