//! BWE Core Engine - lib.rs
//! Modular arithmetic, document graph, signature, storage, parser, optimizer

pub mod arithmetic;
pub mod doc_graph;
pub mod signature;
pub mod storage;
pub mod parser;
pub mod optimizer;

// FFI bridge - publicly exported for Dart
pub mod ffi;

// Re-export common types for FFI use
pub use doc_graph::{DocumentGraph, DocNode, Formatting};
