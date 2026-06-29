//! File parser: .docx, .odt, .rtf, .txt to/from DocumentGraph

use crate::doc_graph::{DocumentGraph, Formatting};
use std::str;

#[derive(Debug, Clone, Copy)]
pub enum FileFormat {
    Docx,
    Odt,
    Rtf,
    Txt,
    Bwe, // Binary Word Engine format
}

pub struct FileParser;

impl FileParser {
    /// Parse file data into a DocumentGraph based on format
    pub fn parse(data: &[u8], format: FileFormat) -> Result<DocumentGraph, String> {
        match format {
            FileFormat::Txt => Self::parse_txt(data),
            FileFormat::Bwe => Self::parse_bwe(data),
            FileFormat::Docx => Err("DOCX parsing not yet implemented (Phase 3)".to_string()),
            FileFormat::Odt => Err("ODT parsing not yet implemented (Phase 3)".to_string()),
            FileFormat::Rtf => Err("RTF parsing not yet implemented (Phase 3)".to_string()),
        }
    }

    /// Serialize a DocumentGraph to bytes in the specified format
    pub fn serialize(graph: &DocumentGraph, format: FileFormat) -> Result<Vec<u8>, String> {
        match format {
            FileFormat::Txt => Self::serialize_txt(graph),
            FileFormat::Bwe => Self::serialize_bwe(graph),
            FileFormat::Docx => Err("DOCX serialization not yet implemented (Phase 3)".to_string()),
            FileFormat::Odt => Err("ODT serialization not yet implemented (Phase 3)".to_string()),
            FileFormat::Rtf => Err("RTF serialization not yet implemented (Phase 3)".to_string()),
        }
    }

    // ===== TXT Format (Phase 1) =====

    /// Parse plaintext file
    fn parse_txt(data: &[u8]) -> Result<DocumentGraph, String> {
        let text = str::from_utf8(data)
            .map_err(|_| "Invalid UTF-8 encoding".to_string())?;

        let mut graph = DocumentGraph::new();

        if !text.is_empty() {
            graph.insert_node(text.to_string(), Formatting::default());
        }

        Ok(graph)
    }

    /// Serialize to plaintext
    fn serialize_txt(graph: &DocumentGraph) -> Result<Vec<u8>, String> {
        let text = graph.get_all_text();
        Ok(text.as_bytes().to_vec())
    }

    // ===== BWE Format (Binary Word Engine) (Phase 1) =====

    /// Parse BWE binary format (JSON-based for now)
    fn parse_bwe(data: &[u8]) -> Result<DocumentGraph, String> {
        let json_str = str::from_utf8(data)
            .map_err(|_| "Invalid UTF-8 in BWE file".to_string())?;

        serde_json::from_str(json_str)
            .map_err(|e| format!("Failed to parse BWE JSON: {}", e))
    }

    /// Serialize to BWE format
    fn serialize_bwe(graph: &DocumentGraph) -> Result<Vec<u8>, String> {
        let json = serde_json::to_string_pretty(graph)
            .map_err(|e| format!("Failed to serialize to JSON: {}", e))?;

        Ok(json.as_bytes().to_vec())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_txt() {
        let data = b"Hello World";
        let graph = FileParser::parse(data, FileFormat::Txt).unwrap();
        assert_eq!(graph.get_all_text(), "Hello World");
    }

    #[test]
    fn test_serialize_txt() {
        let mut graph = DocumentGraph::new();
        graph.insert_node("Hello World".to_string(), Formatting::default());

        let data = FileParser::serialize(&graph, FileFormat::Txt).unwrap();
        let text = String::from_utf8(data).unwrap();
        assert_eq!(text, "Hello World");
    }

    #[test]
    fn test_parse_bwe() {
        let mut graph = DocumentGraph::new();
        graph.insert_node("Test".to_string(), Formatting::default());

        let bwe_data = FileParser::serialize(&graph, FileFormat::Bwe).unwrap();
        let parsed = FileParser::parse(&bwe_data, FileFormat::Bwe).unwrap();

        assert_eq!(parsed.get_all_text(), "Test");
    }

    #[test]
    fn test_round_trip() {
        let original_text = "The quick brown fox jumps over the lazy dog.";

        // TXT round trip
        let data = original_text.as_bytes();
        let graph = FileParser::parse(data, FileFormat::Txt).unwrap();
        let serialized = FileParser::serialize(&graph, FileFormat::Txt).unwrap();
        let result = String::from_utf8(serialized).unwrap();

        assert_eq!(result, original_text);
    }
}
