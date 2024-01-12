use serde::{Deserialize, Serialize};

use crate::app::results::lesson_result_data_object::Sources;

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Quiz{
    pub id: u32,
    // pub quiz_type: i32, // 1 = Identification | 2 = Multiple Choice 
    pub title: String,
    pub target_path: String,
    pub questions: Vec<Question>,
    // pub sources: Sources // Sources from lesson_result_data_object
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type")]
pub enum Question{
    #[serde(rename = "identification")]
    Identification(IdentificationQuestion),
    #[serde(rename = "multipleChoice")]
    MultipleChoice(MultipleChoiceQuestion)
}

impl Default for Question {
    fn default() -> Self {
        Self::MultipleChoice(MultipleChoiceQuestion{
            question: "Question".to_string(),
            choices: Vec::new()
        })
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct IdentificationQuestion{
    pub question: String,
    pub answer: String
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct MultipleChoiceQuestion{
    pub question: String,
    pub choices: Vec<Choice>
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Choice{
    pub content: String,
    pub is_correct: bool
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct QuizzesDataObject{
    pub quizzes: Vec<Quiz>
}