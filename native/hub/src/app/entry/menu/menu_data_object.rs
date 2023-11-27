use serde::{Serialize, Deserialize};

use crate::app::global_objects::lessons_data_object::Lessons;
use crate::app::global_objects::quizzes_data_object::Quizzes;

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct MenuDataObject {
	pub lessons: Lessons,
	pub quizzes: Quizzes, 
}
