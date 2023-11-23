use serde::{Deserialize, Serialize};
use std::fs::{OpenOptions, create_dir_all, File};
use std::io::{self, Write};
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

pub fn write_lessons_to_file(lessons: &Lessons, file_path: &str) -> std::io::Result<()> {
    let json_string = serde_json::to_string_pretty(lessons)?;
    let file = OpenOptions::new()
                    .read(true)
                    .write(true)
                    .create(true)
                    .truncate(true)  // Append mode to preserve existing content
                    .open(file_path);
    match file {
        Ok(mut file) => {
            file.write_all(json_string.as_bytes())?;
        },

        Err(error) => {
            crate::debug_print!("Error in writing to file: '{}'.", error);
            crate::debug_print!("At: {}", file_path);
        }
    }
    Ok(())
}
