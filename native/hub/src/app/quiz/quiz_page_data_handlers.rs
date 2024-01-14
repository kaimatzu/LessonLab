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

use crate::app::entry::{menu, upload};
// Utils
use crate::app::utils::{quiz_generator, scrapers};

// Bridge
use crate::bridge::{RustRequest, RustResponse, RustOperation};

// Data objects
use crate::app::quiz::quiz_specifications_data_object::QuizSpecificationsDataObject;
use crate::app::global_objects::quizzes_data_object::{QuizzesDataObject, Quiz, Question, IdentificationQuestion, MultipleChoiceQuestion, PydanticIdentifications, PydanticMultipleChoices, Choice, PydanticBoth};
use crate::app::entry::menu::menu_data_object::{MenuDataObject, Root};
use crate::app::entry::upload::upload_sources_data_object::UploadSourcesDataObject;
use crate::app::settings::settings_data_object::SettingsDataObject;
use crate::app::results::lesson_result_data_object::Sources;

use crate::messages::quiz;
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
        RustOperation::Read => { // TODO: generate quiz form quiz specs here (python)

            // Start quiz specs test = ===============================

            // crate::debug_print!("quiz_page quiz specs: {:?}", quiz_specifications_data_object.quiz_specifications.clone());

            // End quiz specs test = ===============================

            // start REAL CODE = ===============================
            let message_bytes = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();

            let _ = request_message;

            let response_message;

            let mut sources = Sources::default();

            for file_path in &upload_sources_data_object.file_paths {
                sources.source_files.push(file_path.clone());
            }
            
            for url in &upload_sources_data_object.urls {
                sources.source_urls.push(url.clone());
            }

            for text in &upload_sources_data_object.text_files {
                sources.source_texts.push(text.clone())
            }

            let sanitized_title;
            match quiz_specifications_data_object.quiz_specifications.get(0) {
                Some(title) => {
                    sanitized_title = title.split_at(8).1;
                },
                None => {
                    sanitized_title = "Error_failed_to_get_tile";
                }
            }
            // File path of config.json
            let mut config_file_path = settings_save_directory_data_object.save_directory.clone();
            // File path of target/output.md
            let target_folder_path = format!("{}\\{}", &config_file_path, &sanitized_title);

            match std::fs::create_dir_all(&target_folder_path) {
                Ok(_) => { crate::debug_print!("Successfully created directory"); },
                Err(err) => { crate::debug_print!("Failed to create directory {}", err); },
            }

            let quizzes = menu_data_object.quizzes_data_object.quizzes.clone();

            let mut new_id: u32 = 0;
            for quiz in quizzes {
                new_id = quiz.id;
                new_id += 1;
            }

            // let quiz = Quiz{
            //     id: new_id,
            //     sources,
            //     target_path: target_folder_path.to_owned(),
            //     title: quiz_specifications_data_object.quiz_specifications.get(0).unwrap().clone(),
            //     questions: , // TODO: generate questions from python (AI)
            //     // or save the question in a file
            // };

            config_file_path.push_str("\\config.json");


            // match write_quiz_to_config_file(&quiz, &config_file_path) {
            //     Ok(_) => crate::debug_print!("Successfully write to config file"),
            //     Err(err) => crate::debug_print!("Failed to write to config file: {}", error)
            // }

            let files = upload_sources_data_object.file_paths.clone();
            let urls = upload_sources_data_object.urls.clone();
            
            let title: String;
            let target_path: String;
            match quiz_generator::generate(
                files.clone(), urls.clone(),
                target_folder_path.clone(),
                quiz_specifications_data_object.quiz_specifications.clone()){
                Ok(json) => {
                    // This will return PydanticIdentifications or PydanticMultipleChoices
                    let mut pydantic_identification = PydanticIdentifications::default();
                    let mut pydantic_multiple_choice = PydanticMultipleChoices::default();
                    let mut pydantic_both = PydanticBoth::default();

                    let substring;
                    match quiz_specifications_data_object.quiz_specifications.get(2) {
                        Some(string) => substring = string,
                        None => todo!(),
                    }

                    let mut questions_from_pydantic: Vec<Question> = Vec::new();
                    if substring.contains("Identification") {
                        match serde_json::from_str(&json) {
                            Ok(returned) => pydantic_identification = returned,
                            Err(err) => { crate::debug_print!("Failed to deserialize quiz {}", err); },
                        }

                        for i in 0..pydantic_identification.questions.len() {
                            questions_from_pydantic.push(Question::Identification(IdentificationQuestion {
                                answer: pydantic_identification.questions[i].answer.clone(),
                                question: pydantic_identification.questions[i].question.clone(),
                            }));
                        }
                    } else if substring.contains("Multiple") {
                        match serde_json::from_str(&json) {
                            Ok(returned) =>pydantic_multiple_choice = returned,
                            Err(err) => { crate::debug_print!("Failed to deserialize quiz {}", err); },
                        }
                        for i in 0..pydantic_multiple_choice.questions.len() {
                            questions_from_pydantic.push(Question::MultipleChoice(MultipleChoiceQuestion {
                                question: pydantic_multiple_choice.questions[i].question.clone(),
                                choices: pydantic_multiple_choice.questions[i].choices.clone(),
                            }));
                        }
                    } else {
                        match serde_json::from_str(&json) {
                            Ok(returned) => pydantic_both = returned,
                            Err(err) => { crate::debug_print!("Failed to deserialize quiz {}", err); },
                        }

                        for i in 0..pydantic_both.identification.len() {
                            questions_from_pydantic.push(Question::Identification(IdentificationQuestion { 
                                question: pydantic_both.identification[i].question.clone(),
                                answer: pydantic_both.identification[i].answer.clone(),
                            }));
                        }
                        for i in 0..pydantic_both.multiple_choice.len() {
                            questions_from_pydantic.push(Question::MultipleChoice(MultipleChoiceQuestion {
                                question: pydantic_both.multiple_choice[i].question.clone(),
                                choices: pydantic_both.multiple_choice[i].choices.clone(),
                            }));
                        }
                    }



                    // ----------- Identification

                    // ----------- Multiple Choice
                    // for i in 0..pydantic.questions.len() {
                    //     questions_from_pydantic.push(Question::MultipleChoice(MultipleChoiceQuestion {
                    //         question: pydantic.questions[i].question.clone(),
                    //         choices: pydantic.questions[i].choices.clone(),
                    //     }));
                    // }

                    // ----------- Both
                    // for i in 0..pydantic.questions.len() {
                    //     match pydantic.questions[i].clone() {
                    //         Question::Identification(identification) => {
                    //             questions_from_pydantic.push(Question::Identification(identification));
                    //         },
                    //         Question::MultipleChoice(multiple_choice) => {
                    //             questions_from_pydantic.push(Question::MultipleChoice(multiple_choice));
                    //         },
                    //     }
                    // }
                    
                    let mut quiz_from_pydantic = Quiz {
                        id: new_id.clone(),
                        title: sanitized_title.to_string().clone(),
                        target_path: target_folder_path.clone(),
                        questions: questions_from_pydantic,
                    };

                    quiz_from_pydantic.id = new_id;
                    title = quiz_from_pydantic.title.clone();
                    target_path = quiz_from_pydantic.target_path.clone();
                    let quiz_clone = quiz_from_pydantic.clone();
                    menu_data_object.quizzes_data_object.quizzes.push(quiz_clone);

                    match write_quiz_to_config_file(&quiz_from_pydantic, &config_file_path) {
                        Ok(_) => { crate::debug_print!("Successfully wrote quiz to config.json"); },
                        Err(err) => { crate::debug_print!("Failed to write quiz to config.json {}", err); },
                    }

                    // Init textfiles
                    // for text in quiz_from_json.sources.source_texts {
                    //     text_files.push(TextFileModel {
                    //         title: text.title,
                    //         content: text.content,
                    //     });
                    // }

                    // Init sources

                    let mut text_files = Vec::new();
                    text_files.push(TextFileModel {
                        title: "_".to_string(),
                        content: "_".to_string(),
                    });
                    let sources = SourcesModel {
                        files,
                        urls,
                        texts: text_files
                    };

                    // Init questions
                    let mut questions = Vec::new();
                    for question in quiz_from_pydantic.questions {

                        match question {
                            Question::Identification(identification) => {

                                let question_model = IdentificationQuestionModel {
                                    answer: identification.answer,
                                };

                                questions.push(QuestionModel{
                                    question: identification.question,
                                    r#type: 1,
                                    question_type: Some(QuestionType::Identification(question_model)),
                                });
                            }
                            Question::MultipleChoice(multiple_choice) => {

                                // Create `ChoiceModel` from DTO
                                let mut choices = Vec::new();
                                for choice in multiple_choice.choices {
                                    choices.push(ChoiceModel {
                                        content: choice.content,
                                        is_correct: choice.is_correct,
                                    });
                                }

                                let question_model = MultipleChoiceQuestionModel {
                                    choices,
                                };

                                questions.push(QuestionModel {
                                    question: multiple_choice.question,
                                    r#type: 2,
                                    question_type: Some(QuestionType::MultipleChoice(question_model)),
                                });
                            }
                        }  // end match
                    } // end for questions
                    response_message = ReadResponse {
                        status_code: StatusCode::OK.as_u16() as u32,
                        quiz_model: Some(QuizModel{
                            id: new_id,
                            title,
                            target_path,
                            questions,
                            sources: Some(sources),
                        })
                    }
                }, // end Ok()
                Err(err) => {
                    crate::debug_print!("{:?}", err.to_string());
                    response_message = ReadResponse {
                        status_code: StatusCode::NOT_FOUND.as_u16() as u32,
                        quiz_model: None
                    };
                }
            }
            
            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
            // end REAL CODE = ===============================

            // Start TEST = ===============================
            // let mut test_source_files = Vec::new();
            // let mut test_source_urls = Vec::new();
            // let mut test_source_texts = Vec::new();
            // let mut test_questions = Vec::new();
            // let mut test_choices = Vec::new();
            // for i in 0..3 {
            //     let correct: bool;
            //     if i == 0 {
            //         correct = true
            //     } else {
            //         correct = false
            //     }
            //     test_choices.push(ChoiceModel {
            //         content: "Rust test choice ".to_string() + &i.to_string(),
            //         is_correct: correct,
            //     });
            // }
            // test_source_files.push("rust_test_source_files".to_string());
            // test_source_urls.push("rust_test_source_urls".to_string());
            // test_source_texts.push(TextFileModel {
            //     title: "Rust Test Title".to_string(),
            //     content: "Rust test content".to_string(),
            // });
            // for i in 0..3 {
            //     for j in 0..3 {
            //         let correct: bool;
            //         if j == i {
            //             correct = true
            //         } else {
            //             correct = false
            //         }
            //         test_choices.push(ChoiceModel {
            //             content: "Rust test choice ".to_string() + &j.to_string(),
            //             is_correct: correct,
            //         });
            //     }
            //     test_questions.push(QuestionModel {
            //         question: "Rust test question ".to_string() + &i.to_string(),
            //         r#type: 2,
            //         question_type: Some(QuestionType::MultipleChoice(MultipleChoiceQuestionModel{
            //             choices: test_choices.clone(),
            //         })),
            //     });
            //     for _ in 0..3{
            //         test_choices.remove(0);
            //     }
            // }
            // test_questions.push(QuestionModel {
            //     question: "Test identification question".to_string(),
            //     r#type: 1,
            //     question_type: Some(QuestionType::Identification(IdentificationQuestionModel{
            //         answer: "Test identification answer".to_string(),
            //     })),
            // });
            // RustResponse {
            //     successful: true,
            //     message: Some(ReadResponse {
            //         status_code: StatusCode::OK.as_u16() as u32,
            //         quiz_model: Some(QuizModel {
            //             id: 100,
            //             title: "rust_test_quiz".to_string(),
            //             target_path: "rust_test_target_path".to_string(),
            //             questions: test_questions,
            //             sources: Some(SourcesModel {
            //                 files: test_source_files,
            //                 urls: test_source_urls,
            //                 texts: test_source_texts,
            //             }),
            //         }),
            //     }.encode_to_vec()),
            //     blob: None,
            // }
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