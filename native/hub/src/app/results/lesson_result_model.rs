use serde::{Deserialize, Serialize};
use crate::app::entry::upload::upload_model::TextFile;

pub struct LessonResultModel {
    title: String,
    md_contents: String
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Sources{
    pub source_files: Vec<String>,
    pub source_urls: Vec<String>,
    pub source_texts: Vec<TextFile>
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Lesson{
    pub title: String,
    pub target_path: String,
    pub sources: Sources
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Lessons{
    pub lessons: Vec<Lesson>
}
