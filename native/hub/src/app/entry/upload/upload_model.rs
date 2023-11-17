#[derive(Default)]
pub struct UploadModel {
    pub file_paths: Vec<String>,
    pub urls: Vec<String>,
    pub text_files: Vec<TextFile>
}

#[derive(Clone)]
pub struct TextFile {
    pub title: String,
    pub content: String
}
