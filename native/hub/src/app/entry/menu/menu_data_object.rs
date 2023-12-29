use serde::{Serialize, Deserialize};

use crate::app::global_objects::lessons_data_object::LessonsDataObject;
use crate::app::global_objects::quizzes_data_object::QuizzesDataObject;

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct MenuDataObject {
	pub lessons_data_object: LessonsDataObject,
	pub quizzes_data_object: QuizzesDataObject, 
    pub id_head: i32
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Root {
	pub menu_data_object: MenuDataObject,
}