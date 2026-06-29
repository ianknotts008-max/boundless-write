//! Document structural graph model
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocNode {
    pub id: u64,
    pub node_type: NodeType,
    pub text: String,
    pub formatting: Formatting,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum NodeType {
    Text,
    Paragraph,
    Heading(u8),     // 1-6
    BulletListItem,
    NumberedListItem,
    TableCell,
    Image,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocEdge {
    pub from: u64,
    pub to: u64,
    pub relation: EdgeType,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum EdgeType {
    Next,
    Child,
    Parent,
    Reference,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Formatting {
    pub bold: bool,
    pub italic: bool,
    pub underline: bool,
    pub strikethrough: bool,
    pub font_family: String,
    pub font_size: f32,
    pub font_color: String,       // Hex color
    pub background_color: String, // Hex color
    pub alignment: String,        // "left", "center", "right", "justify"
}

impl Default for Formatting {
    fn default() -> Self {
        Self {
            bold: false,
            italic: false,
            underline: false,
            strikethrough: false,
            font_family: "Roboto".to_string(),
            font_size: 12.0,
            font_color: "#000000".to_string(),
            background_color: "#FFFFFF".to_string(),
            alignment: "left".to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentGraph {
    pub nodes: Vec<DocNode>,
    pub edges: Vec<DocEdge>,
    pub next_id: u64,
}

impl DocumentGraph {
    pub fn new() -> Self {
        Self {
            nodes: vec![],
            edges: vec![],
            next_id: 1,
        }
    }

    /// Insert a text node and return its ID
    pub fn insert_node(&mut self, text: String, formatting: Formatting) -> u64 {
        let id = self.next_id;
        self.next_id += 1;

        let node = DocNode {
            id,
            node_type: NodeType::Text,
            text,
            formatting,
        };

        self.nodes.push(node);
        id
    }

    /// Insert text at a specific position
    pub fn insert_text_at(&mut self, node_id: u64, text: &str, position: usize) -> Result<(), String> {
        let node = self.nodes.iter_mut().find(|n| n.id == node_id)
            .ok_or_else(|| "Node not found".to_string())?;

        if position > node.text.len() {
            return Err("Position out of bounds".to_string());
        }

        node.text.insert_str(position, text);
        Ok(())
    }

    /// Delete text from a node
    pub fn delete_text(&mut self, node_id: u64, start: usize, end: usize) -> Result<(), String> {
        let node = self.nodes.iter_mut().find(|n| n.id == node_id)
            .ok_or_else(|| "Node not found".to_string())?;

        if end > node.text.len() || start > end {
            return Err("Invalid range".to_string());
        }

        node.text.drain(start..end);
        Ok(())
    }

    /// Add an edge between nodes
    pub fn add_edge(&mut self, from: u64, to: u64, relation: EdgeType) -> Result<(), String> {
        if !self.nodes.iter().any(|n| n.id == from) {
            return Err("From node not found".to_string());
        }
        if !self.nodes.iter().any(|n| n.id == to) {
            return Err("To node not found".to_string());
        }

        self.edges.push(DocEdge { from, to, relation });
        Ok(())
    }

    /// Get a node by ID
    pub fn get_node(&self, id: u64) -> Option<&DocNode> {
        self.nodes.iter().find(|n| n.id == id)
    }

    /// Get all nodes as text (concatenated)
    pub fn get_all_text(&self) -> String {
        self.nodes.iter().map(|n| &n.text).cloned().collect::<Vec<_>>().join("")
    }

    /// Get word count
    pub fn word_count(&self) -> usize {
        let all_text = self.get_all_text();
        all_text.split_whitespace().count()
    }

    /// Get character count
    pub fn char_count(&self) -> usize {
        self.get_all_text().len()
    }

    /// Get page count (approximate: 3000 chars per page)
    pub fn page_count(&self) -> usize {
        ((self.char_count() as f32) / 3000.0).ceil() as usize
    }

    /// Clear the entire document
    pub fn clear(&mut self) {
        self.nodes.clear();
        self.edges.clear();
        self.next_id = 1;
    }

    /// Get all nodes
    pub fn nodes(&self) -> &[DocNode] {
        &self.nodes
    }

    /// Get all edges
    pub fn edges(&self) -> &[DocEdge] {
        &self.edges
    }
}

impl Default for DocumentGraph {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_insert_node() {
        let mut graph = DocumentGraph::new();
        let id = graph.insert_node("Hello".to_string(), Formatting::default());
        assert_eq!(graph.nodes.len(), 1);
        assert_eq!(graph.get_node(id).unwrap().text, "Hello");
    }

    #[test]
    fn test_insert_text_at() {
        let mut graph = DocumentGraph::new();
        let id = graph.insert_node("Hello World".to_string(), Formatting::default());
        graph.insert_text_at(id, " Beautiful", 5).unwrap();
        assert_eq!(graph.get_node(id).unwrap().text, "Hello Beautiful World");
    }

    #[test]
    fn test_delete_text() {
        let mut graph = DocumentGraph::new();
        let id = graph.insert_node("Hello World".to_string(), Formatting::default());
        graph.delete_text(id, 5, 11).unwrap();
        assert_eq!(graph.get_node(id).unwrap().text, "Hello");
    }

    #[test]
    fn test_word_count() {
        let mut graph = DocumentGraph::new();
        graph.insert_node("Hello World Test".to_string(), Formatting::default());
        assert_eq!(graph.word_count(), 3);
    }

    #[test]
    fn test_char_count() {
        let mut graph = DocumentGraph::new();
        graph.insert_node("Hello".to_string(), Formatting::default());
        assert_eq!(graph.char_count(), 5);
    }
}
