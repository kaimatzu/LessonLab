use serde::{Deserialize, Serialize};
use crate::app::entry::upload::upload_sources_data_object::TextFile;

pub struct LessonResultDataObject {
    title: String,
    md_contents: String
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Sources{
    pub source_files: Vec<String>,
    pub source_urls: Vec<String>,
    pub source_texts: Vec<TextFile>
}