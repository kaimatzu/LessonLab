use serde::{Deserialize, Serialize};
use crate::app::results::lesson_result_data_object::Sources;

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Lesson{
	pub id: u32,
    pub title: String,
    pub target_path: String,
    pub sources: Sources
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct LessonsDataObject{
    pub lessons: Vec<Lesson>
}
