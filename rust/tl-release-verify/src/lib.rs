//! Release-artifact checking for the files this repository publishes for download.
//!
//! A manifest is the GNU `sha256sum` format: one `<64 lowercase hex>  <path>` or
//! `<hex> *<path>` line per artifact. Paths are relative, `/`-separated, and may not
//! escape the release directory. A matching digest proves only that the file equals
//! what the manifest names; if the manifest comes from the same place as the file it
//! authenticates nothing (see `VERIFY.md`). No signature scheme is implemented here.
#![forbid(unsafe_code)]

use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fmt;

pub const MAX_ENTRIES: usize = 1_000;
pub const MAX_PATH: usize = 255;

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum ManifestError {
    /// 1-based line number.
    Syntax(usize),
    BadPath(usize),
    Duplicate(usize),
    TooManyEntries,
    Empty,
}

impl fmt::Display for ManifestError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{self:?}")
    }
}
impl std::error::Error for ManifestError {}

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Entry {
    pub path: String,
    pub sha256: [u8; 32],
}

/// Safe relative path: non-empty `/`-separated segments of `[A-Za-z0-9._ -]`, no
/// segment `.`/`..`, no leading `/` or `-`, at most 255 bytes.
pub fn safe_path(p: &str) -> bool {
    !p.is_empty()
        && p.len() <= MAX_PATH
        && !p.starts_with('-')
        && p.split('/').all(|seg| {
            !seg.is_empty()
                && seg != "."
                && seg != ".."
                && !seg.starts_with(' ')
                && !seg.ends_with(' ')
                && seg
                    .bytes()
                    .all(|b| b.is_ascii_alphanumeric() || b"._- ".contains(&b))
        })
}

fn hex32(s: &str) -> Option<[u8; 32]> {
    if s.len() != 64 {
        return None;
    }
    let mut out = [0u8; 32];
    for (i, pair) in s.as_bytes().chunks_exact(2).enumerate() {
        let hi = (pair[0] as char).to_digit(16)?;
        let lo = (pair[1] as char).to_digit(16)?;
        if pair.iter().any(|b| b.is_ascii_uppercase()) {
            return None;
        }
        out[i] = (hi * 16 + lo) as u8;
    }
    Some(out)
}

pub fn hex(d: &[u8; 32]) -> String {
    d.iter().map(|b| format!("{b:02x}")).collect()
}

/// Parse a manifest. Blank lines are ignored; everything else must be an entry.
pub fn parse_manifest(text: &str) -> Result<Vec<Entry>, ManifestError> {
    let mut seen = BTreeMap::new();
    for (i, raw) in text.lines().enumerate() {
        let n = i + 1;
        let line = raw.strip_suffix('\r').unwrap_or(raw);
        if line.is_empty() {
            continue;
        }
        let (digest, rest) = line.split_at_checked(64).ok_or(ManifestError::Syntax(n))?;
        let path = rest
            .strip_prefix("  ")
            .or_else(|| rest.strip_prefix(" *"))
            .ok_or(ManifestError::Syntax(n))?;
        let sha256 = hex32(digest).ok_or(ManifestError::Syntax(n))?;
        if !safe_path(path) {
            return Err(ManifestError::BadPath(n));
        }
        if seen.contains_key(path) {
            return Err(ManifestError::Duplicate(n));
        }
        if seen.len() >= MAX_ENTRIES {
            return Err(ManifestError::TooManyEntries);
        }
        seen.insert(path.to_owned(), sha256);
    }
    if seen.is_empty() {
        return Err(ManifestError::Empty);
    }
    Ok(seen
        .into_iter()
        .map(|(path, sha256)| Entry { path, sha256 })
        .collect())
}

/// Deterministic manifest (sorted by path, binary-mode marker as `sha256sum -b`).
pub fn render_manifest(entries: &[Entry]) -> String {
    let mut sorted: Vec<&Entry> = entries.iter().collect();
    sorted.sort();
    sorted
        .iter()
        .map(|e| format!("{} *{}\n", hex(&e.sha256), e.path))
        .collect()
}

pub fn sha256(bytes: &[u8]) -> [u8; 32] {
    Sha256::digest(bytes).into()
}

/// Incremental hashing for large artifacts.
#[derive(Default)]
pub struct Hasher(Sha256);

impl Hasher {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn update(&mut self, chunk: &[u8]) {
        self.0.update(chunk);
    }
    pub fn finish(self) -> [u8; 32] {
        self.0.finalize().into()
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Outcome {
    Ok,
    Missing,
    Mismatch { actual: [u8; 32] },
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Report {
    pub results: Vec<(String, Outcome)>,
    /// Artifacts present but not listed in the manifest.
    pub unlisted: Vec<String>,
}

impl Report {
    /// Every listed artifact is present with the listed digest and nothing is unlisted.
    pub fn all_ok(&self) -> bool {
        self.unlisted.is_empty() && self.results.iter().all(|(_, o)| *o == Outcome::Ok)
    }
}

/// Compare a manifest with computed digests of the files actually present.
pub fn verify(entries: &[Entry], present: &BTreeMap<String, [u8; 32]>) -> Report {
    let results = entries
        .iter()
        .map(|e| {
            let outcome = match present.get(&e.path) {
                None => Outcome::Missing,
                Some(d) if *d == e.sha256 => Outcome::Ok,
                Some(d) => Outcome::Mismatch { actual: *d },
            };
            (e.path.clone(), outcome)
        })
        .collect();
    let unlisted = present
        .keys()
        .filter(|p| !entries.iter().any(|e| &e.path == *p))
        .cloned()
        .collect();
    Report { results, unlisted }
}
