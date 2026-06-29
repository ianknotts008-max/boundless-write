//! Signature engine: vector-based signature capture and cryptographic binding
use serde::{Serialize, Deserialize};
use sha2::{Sha256, Digest};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SignatureStroke {
    pub points: Vec<(f32, f32)>,
    pub pressure: Option<Vec<f32>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Signature {
    pub strokes: Vec<SignatureStroke>,
    pub signer_id: String,
    pub signature_hash: String,
}

impl Signature {
    pub fn new(strokes: Vec<SignatureStroke>, signer_id: String) -> Self {
        let mut hasher = Sha256::new();
        for stroke in &strokes {
            for &(x, y) in &stroke.points {
                hasher.update(x.to_le_bytes());
                hasher.update(y.to_le_bytes());
            }
        }
        hasher.update(signer_id.as_bytes());
        let signature_hash = hex::encode(hasher.finalize());
        Self { strokes, signer_id, signature_hash }
    }
}
