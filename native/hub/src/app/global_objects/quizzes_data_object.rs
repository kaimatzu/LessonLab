use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Quiz{
    pub id: u32,
    pub title: String,
    pub target_path: String,
    pub questions: Vec<Question>
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct Question{
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