use serde::{Deserialize, Serialize};

#[derive(Default)]
pub struct UploadSourcesDataObject {
    pub file_paths: Vec<String>,
    pub urls: Vec<String>,
    pub text_files: Vec<TextFile>
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct TextFile {
    pub title: String,
    pub content: String
}
