use std::any::Any;
// File
use std::fs::{OpenOptions, create_dir_all, File};
use std::io::{self, Write, Read};

// thread
use std::thread::sleep;

// HTTP
use http::StatusCode;
use prost::Message;
use tokio_with_wasm::tokio;

use crate::app::entry::menu;
// Utils
use crate::app::utils::{quiz_generator, scrapers};

// Bridge
use crate::bridge::{RustRequest, RustResponse, RustOperation};

// Data objects
use crate::app::quiz::quiz_specifications_data_object::QuizSpecificationsDataObject;
use crate::app::global_objects::quizzes_data_object::{QuizzesDataObject, Quiz, Question, IdentificationQuestion, MultipleChoiceQuestion};
use crate::app::entry::menu::menu_data_object::{MenuDataObject, Root};
use crate::app::entry::upload::upload_sources_data_object::UploadSourcesDataObject;
use crate::app::settings::settings_data_object::SettingsDataObject;
use crate::app::results::lesson_result_data_object::Sources;

use crate::messages::quiz::quiz_page::question_model::QuestionType;
// Messages
use crate::messages::quiz::quiz_page::{
    ReadResponse,
    CreateResponse,
    ReadRequest,
    QuizModel,
    QuestionModel,
    IdentificationQuestionModel,
    MultipleChoiceQuestionModel,
    ChoiceModel,
    Sources as SourcesModel,
    TextFile as TextFileModel
};

impl QuizzesDataObject {
    fn create_quiz(&mut self, new_quiz: Quiz) {
        if !self.quizzes.iter().any(|quiz| quiz.target_path == new_quiz.target_path) {
            self.quizzes.push(new_quiz);
            crate::debug_print!("Quiz added successfully!");
        } else {
            crate::debug_print!("Error: Duplicate target_path found. Quiz not added.");
        }
    }

    fn remove_quiz(&mut self, target_path: &str) {
        if let Some(index) = self.quizzes.iter().position(|quiz| quiz.target_path == target_path) {
            self.quizzes.remove(index);
            crate::debug_print!("Quiz with target_path '{}' removed successfully!", target_path);
        } else {
            crate::debug_print!("Error: Quiz with target_path '{}' not found.", target_path);
        }
    }
}

pub async fn handle_quiz_generation(rust_request: RustRequest,
    upload_sources_data_object: &mut tokio::sync::MutexGuard<'_, UploadSourcesDataObject>,
    quiz_specifications_data_object: &mut tokio::sync::MutexGuard<'_, QuizSpecificationsDataObject>,
    settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>,
    menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>) -> RustResponse {

    match rust_request.operation {
        RustOperation::Create => {
            RustResponse {
                successful: false,
                message: Some(CreateResponse{status_code: StatusCode::NOT_IMPLEMENTED.as_u16() as u32}.encode_to_vec()),
                blob: None,
            }
        }
        RustOperation::Read => { // TODO: generate quiz from quiz specs here (python)
            // start REAL CODE = ===============================
            // let message_bytes = rust_request.message.unwrap();
            // let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();

            // let _ = request_message;

            // let response_message;

            // let mut string_payload: String = String::from("Quiz Specifications \n");
            
            // // let quizzes_json = QuizzesDataObject { quizzes: Vec::new() };
            // let mut sources = Sources::default();

            // for quiz_specification in &quiz_specifications_data_object.quiz_specifications {
            //     string_payload.push_str(&quiz_specification);
            //     string_payload.push_str("\n"); 
            //     crate::debug_print!("Quiz Spec: {}", &quiz_specification);
            // }

            // string_payload.push_str("------------------------------- \n");

            // for file_path in &upload_sources_data_object.file_paths {
            //     if file_path.to_lowercase().ends_with(".pdf") {
            //         // TODO: Implement other scrapers for other text file formats
            //         match scrapers::scrape_pdf(file_path.to_string()) {
            //             Ok(pdf_content) => {
            //                 string_payload.push_str(&pdf_content);
            //                 string_payload.push_str("\n"); 
            //                 sources.source_files.push(file_path.clone())
            //             }
            //             Err(err) => {
            //                 crate::debug_print!("[Scraper] >>> {} ", err);
            //             }
            //         }
            //     }
            // }
            
            // for url in &upload_sources_data_object.urls {
            //     match scrapers::scrape_url(url.to_string()) {
            //         Ok(web_content) => {
            //             string_payload.push_str(&web_content);
            //             string_payload.push_str("\n"); 
            //             sources.source_urls.push(url.clone())
            //         }
            //         Err(err) => {
            //                 crate::debug_print!("[Scraper] >>> {} ", err);
            //         }
            //     }
            // }

            // for text in &upload_sources_data_object.text_files {
            //     string_payload.push_str(&text.title);
            //     string_payload.push_str("\n"); 
            //     string_payload.push_str(&text.content);
            //     string_payload.push_str("\n"); 
            //     sources.source_texts.push(text.clone())
            // }

            // // let sanitized_title = quiz_specifications_data_object.quiz_specifications.get(0).unwrap().clone().replace(" ", "_");
            // let sanitized_title;
            // match quiz_specifications_data_object.quiz_specifications.get(0) {
            //     Some(title) => {
            //         sanitized_title = title.clone().replace(" ", "_");
            //     }
            //     None => {
            //         sanitized_title = "Error_failed_to_get_tile".to_string();
            //     }
            // }
            // // File path of config.json
            // let mut config_file_path = settings_save_directory_data_object.save_directory.clone();
            // // File path of target/output.md
            // let target_folder_path = format!("{}\\{}", &config_file_path, &sanitized_title);

            // if let Err(error) = std::fs::create_dir_all(&target_folder_path) {
            //     crate::debug_print!("Failed to create folder: {}", error);
            // }

            // let quizzes = menu_data_object.quizzes_data_object.quizzes.clone();

            // let mut new_id: u32 = 0;
            // for quiz in quizzes {
            //     new_id = quiz.id;
            //     new_id += 1;
            // }

            // // let quiz = Quiz{
            // //     id: new_id,
            // //     sources,
            // //     target_path: target_folder_path.to_owned(),
            // //     title: quiz_specifications_data_object.quiz_specifications.get(0).unwrap().clone(),
            // //     questions: , // TODO: generate questions from python (AI)
            // //     // or save the question in a file
            // // };

            // config_file_path.push_str("\\config.json");

            // let title: String;
            // let target_path: String;
            // match quiz_generator::generate(string_payload) {
            //     Ok(json) => {
            //         // TODO: generate quiz from json string

            //         // TODO: Handle this do not panic
            //         let mut quiz_from_json: Quiz = serde_json::from_str(&json).unwrap_or_else(|e| {
            //             crate::debug_print!("Failed to deserialize Root.");
            //              panic!("Error deserializing Quiz: {}", e);
            //         });
            //         quiz_from_json.id = new_id;
            //         title = quiz_from_json.title.clone();
            //         target_path = quiz_from_json.target_path.clone();
            //         let quiz_clone = quiz_from_json.clone();
            //         menu_data_object.quizzes_data_object.quizzes.push(quiz_clone);
            //         if let Err(error) = write_quiz_to_config_file(&quiz_from_json, &config_file_path) {
            //             crate::debug_print!("Failed to write to config file: {}", error);
            //         }

            //         // Init textfiles
            //         let mut text_files = Vec::new();
            //         for text in quiz_from_json.sources.source_texts {
            //             text_files.push(TextFileModel {
            //                 title: text.title,
            //                 content: text.content,
            //             });
            //         }

            //         // Init sources
            //         let sources = SourcesModel {
            //             files: quiz_from_json.sources.source_files,
            //             urls: quiz_from_json.sources.source_urls,
            //             texts: text_files,
            //         };

            //         // Init questions
            //         let mut questions = Vec::new();
            //         for question in quiz_from_json.questions {

            //             match question {
            //                 Question::Identification(identification) => {

            //                     let question_model = IdentificationQuestionModel {
            //                         answer: identification.answer,
            //                     };

            //                     questions.push(QuestionModel{
            //                         question: identification.question,
            //                         r#type: 1,
            //                         question_type: Some(QuestionType::Identification(question_model)),
            //                     });
            //                 }
            //                 Question::MultipleChoice(multiple_choice) => {

            //                     // Create `ChoiceModel` from DTO
            //                     let mut choices = Vec::new();
            //                     for choice in multiple_choice.choices {
            //                         choices.push(ChoiceModel {
            //                             content: choice.content,
            //                             is_correct: choice.is_correct,
            //                         });
            //                     }

            //                     let question_model = MultipleChoiceQuestionModel {
            //                         choices,
            //                     };

            //                     questions.push(QuestionModel{
            //                         question: multiple_choice.question,
            //                         r#type: 2,
            //                         question_type: Some(QuestionType::MultipleChoice(question_model)),
            //                     });
            //                 }
            //             }  // end match
            //         } // end for questions
            //         response_message = ReadResponse {
            //             status_code: StatusCode::OK.as_u16() as u32,
            //             quiz_model: Some(QuizModel{
            //                 id: new_id,
            //                 title,
            //                 target_path,
            //                 questions,
            //                 sources: Some(sources),
            //             })
            //         }
            //     } // end Ok()
            //     Err(err) => {
            //         crate::debug_print!("{:?}", err.to_string());
            //         response_message = ReadResponse {
            //             status_code: StatusCode::NOT_FOUND.as_u16() as u32,
            //             quiz_model: None
            //         };
            //     }
            // }
            // 
            // RustResponse {
            //     successful: true,
            //     message: Some(response_message.encode_to_vec()),
            //     blob: None,
            // }
            // end REAL CODE = ===============================

            // Start TEST = ===============================
            let mut test_source_files = Vec::new();
            let mut test_source_urls = Vec::new();
            let mut test_source_texts = Vec::new();
            let mut test_questions = Vec::new();
            let mut test_choices = Vec::new();
            for i in 0..3 {
                let correct: bool;
                if i == 0 {
                    correct = true
                } else {
                    correct = false
                }
                test_choices.push(ChoiceModel {
                    content: "Rust test choice ".to_string() + &i.to_string(),
                    is_correct: correct,
                });
            }
            test_source_files.push("rust_test_source_files".to_string());
            test_source_urls.push("rust_test_source_urls".to_string());
            test_source_texts.push(TextFileModel {
                title: "Rust Test Title".to_string(),
                content: "Rust test content".to_string(),
            });
            for i in 0..3 {
                test_questions.push(QuestionModel {
                    question: "Rust test question ".to_string() + &i.to_string(),
                    r#type: 2,
                    question_type: Some(QuestionType::MultipleChoice(MultipleChoiceQuestionModel{
                        choices: test_choices.clone(),
                    })),
                });
            }
            test_questions.push(QuestionModel {
                question: "Test identification question".to_string(),
                r#type: 1,
                question_type: Some(QuestionType::Identification(IdentificationQuestionModel{
                    answer: "Test identification answer".to_string(),
                })),
            });
            RustResponse {
                successful: true,
                message: Some(ReadResponse {
                    status_code: StatusCode::NOT_FOUND.as_u16() as u32,
                    quiz_model: Some(QuizModel {
                        id: 100,
                        title: "rust_test_quiz".to_string(),
                        target_path: "rust_test_target_path".to_string(),
                        questions: test_questions,
                        sources: Some(SourcesModel {
                            files: test_source_files,
                            urls: test_source_urls,
                            texts: test_source_texts,
                        }),
                    }),
                }.encode_to_vec()),
                blob: None,
            } 
            // End TEST = ===============================
        }
        RustOperation::Update => {
            RustResponse {
                successful: false,
                message: Some(CreateResponse{status_code: StatusCode::NOT_IMPLEMENTED.as_u16() as u32}.encode_to_vec()),
                blob: None,
            }
        }
        RustOperation::Delete => {
            RustResponse {
                successful: false,
                message: Some(CreateResponse{status_code: StatusCode::NOT_IMPLEMENTED.as_u16() as u32}.encode_to_vec()),
                blob: None,
            }
        }

    }

}

pub fn write_quiz_to_config_file(current_quiz: &Quiz, file_path: &str) -> std::io::Result<()> {
    // crate::debug_print!("Deserializing...");

    // Load all quizzes in the config file and Deserialize the JSON string
    let mut root: Root = {
        // crate::debug_print!("Reading File: {}", file_path);
        let mut file = File::open(file_path)?;
        let mut contents = String::new();
        file.read_to_string(&mut contents)?;

        // Deserialize the JSON string into Root
        serde_json::from_str(&contents).unwrap_or_else(|e| {
            // Handle deserialization error, for simplicity, panicking in case of an error
            crate::debug_print!("Failed to deserialize Root.");
            panic!("Error deserializing Root: {}", e);
        })
    };

    // Add the current quiz to the lessons in the root
    root.menu_data_object.quizzes_data_object.quizzes.push(current_quiz.to_owned());

    // crate::debug_print!("Deserialized:");
    // for quizzes in &root.menu_data_object.quizzes_data_object.quizzes {
    //     crate::debug_print!("{:#?}", quiz);
    // }

    // Serialize the root into JSON again
    let updated_json_string = serde_json::to_string_pretty(&root)?;

    // Truncate the config file
    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(file_path)?;

    // Write the updated JSON string to the file
    file.write_all(updated_json_string.as_bytes())?;

    Ok(())
}