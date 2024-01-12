use http::StatusCode;
use crate::app::entry::menu;
use crate::app::entry::upload::upload_sources_data_object::TextFile;
use crate::app::global_objects::lessons_data_object::{
    LessonsDataObject,
    Lesson
};
use crate::app::global_objects::quizzes_data_object::{
    self,
    QuizzesDataObject,
    Quiz,
    Question,
    Choice,
    MultipleChoiceQuestion,
    IdentificationQuestion,
};
use crate::app::lesson;
use crate::app::results::lesson_result_data_object::Sources;
use crate::app::settings::settings_data_object::SettingsDataObject;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use crate::messages::entry::menu::menu::{
    MenuModel as RinfMenuModel,
    LessonModel as RinfLessonModel,
    QuizModel as RinfQuizModel,
    QuestionModel as RinfQuestionModel,
    Sources as RinfMenuSource,
    question_model::QuestionType as MenuQuestionType
};

use crate::messages::entry::upload::uploaded_content;

use std::any::Any;
use std::fs::{File, OpenOptions, remove_dir_all};
use std::io::{Read, Write};
use prost::Message;

use tokio_with_wasm::tokio;
use crate::app::entry::menu::menu_data_object::{MenuDataObject, Root};

// Temporary code
// function to handle CRUD for lesson only
// pub async fn handle_lesson_crud(rust_request: RustRequest) -> RustResponse {
//     use crate::messages::entry::menu::menu::{ReadRequest, ReadResponse};

//     match rust_request.operation {
//         RustOperation::Create => RustResponse::default(),
//         RustOperation::Read => RustResponse::default(),
//         RustOperation::Update => RustResponse::default(),
//         RustOperation::Delete => RustResponse::default(),
//     }
// }

// Temporary code
// function to handle CRUD for quiz only
// pub async fn handle_quiz_crud(rust_request: RustRequest) -> RustResponse {
//     use crate::messages::entry::menu::menu::{ReadRequest, ReadResponse};

//     match rust_request.operation {
//         RustOperation::Create => RustResponse::default(),
//         RustOperation::Read => RustResponse::default(),
//         RustOperation::Update => RustResponse::default(),
//         RustOperation::Delete => RustResponse::default(),
//     }

// }

/// Handles the CRUD for the data in Menu screen
/// @see menu_connection_orchestrator.dart
/// @see MenuConnectionOrchestrator
pub async fn handle_menu_content_loading(
    rust_request: RustRequest,
    menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>,
    settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>) -> RustResponse {

    use crate::messages::entry::menu::menu::{
        ReadRequest,
        ReadResponse,
        UpdateRequest,
        UpdateResponse,
        DeleteRequest,
        DeleteResponse
    };

    match rust_request.operation {
        RustOperation::Create => RustResponse::default(),

        // Loads data in the specified path in the sharedpreferences.json
        // using the metadata in config.json file
        // and the returned value of this function is passed to the MenuConnectionOrchestrator in Dart
        // @see menu_connection_orchestrator.dart
        RustOperation::Read => {
            // Debug purposes. Just to check if the uploaded files are stored in main().
            let message_bytes = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();

            let _ = request_message;

            // Get the save directory from settings
            let mut file_path = settings_save_directory_data_object.save_directory.clone();
            file_path.push_str("\\config.json");

            // Get lesson and quiz data from saved files
            let response_message;
            match load_menu_data_from_file(file_path.as_str()) {
                Some (temp_menu_data_object) => {
                    menu_data_object.lessons_data_object = temp_menu_data_object.lessons_data_object;
                    menu_data_object.quizzes_data_object = temp_menu_data_object.quizzes_data_object; 
                    // Create message
                    response_message = ReadResponse {
                        menu_model: serialize_menu_model(menu_data_object)
                    }
                },
                None => {
                    // Create empty model as message
                    response_message = ReadResponse {
                        menu_model: Some(RinfMenuModel {
                            lessons: Vec::new(),
                            quizzes: Vec::new(),
                        }),
                    };
                },
            }


            // Create rust response to send to dart
            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        },
        RustOperation::Update => {
            let message_bytes = rust_request.message.unwrap();
            // The data from Dart (MenuModel data from Dart)
            let request_message = UpdateRequest::decode(message_bytes.as_slice()).unwrap();

            // Get the save directory from settings
            let mut file_path = settings_save_directory_data_object.save_directory.clone();
            file_path.push_str("\\config.json");

            // Write lesson data to files
            let result: std::io::Result<()>;
            if request_message.is_lesson {
                result = update_lesson_file(
                    file_path.as_str(),
                    menu_data_object,
                    request_message.lesson.unwrap()
                );
            } else {
                result = update_quiz_file(
                    file_path.as_str(),
                    menu_data_object,
                    request_message.quiz.unwrap()
                );
            }

            let response_message: UpdateResponse = {
                if result.is_ok() {
                    UpdateResponse {
                        status_code: 200,
                    }
                } else {
                    UpdateResponse {
                        status_code: 500
                    }
                }
            };

            // Create rust response to send to dart
            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        },
        RustOperation::Delete => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = DeleteRequest::decode(message_bytes.as_slice()).unwrap();

            // Get the save directory from settings
            let mut file_path = settings_save_directory_data_object.save_directory.clone();
            file_path.push_str("\\config.json");

            // Write lesson data to files
            let result: std::io::Result<()>;
            if request_message.is_lesson {
                result = delete_lesson_file(file_path.as_str(), menu_data_object, request_message.id);
            } else {
                result = delete_quiz_file(file_path.as_str(), menu_data_object, request_message.id);
            }

            // let mut code: u32;
            let code = match result {
                Ok(_) => 200,
                Err(_) => 300,
            };

            let response_message = DeleteResponse {
                status_code: code,
            };

            // Create rust response to send to dart
            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        },
    }
}

/// Creates a `MenuModel` from `MenuDataObject`
/// @author Karl Villardar
fn serialize_menu_model(menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>) -> Option<RinfMenuModel> {
    // Logic to create a MenuModel
    let mut lessons: Vec<RinfLessonModel> = Vec::new();
    for lesson in menu_data_object.lessons_data_object.lessons.clone() {
        let mut lesson_model: RinfLessonModel = RinfLessonModel::default();
        lesson_model.title = lesson.title;
        lesson_model.id = lesson.id;
        // TODO: Need to load content form target. Use a file opener
        lesson_model.location = lesson.target_path;
        lessons.push(lesson_model);
    }

    let mut quizzes: Vec<RinfQuizModel> = Vec::new();
    for quiz in menu_data_object.quizzes_data_object.quizzes.clone() {
        let mut quiz_model: RinfQuizModel = RinfQuizModel::default();
        quiz_model.title = quiz.title;
        quiz_model.location = quiz.target_path;
        quiz_model.id = quiz.id;
        
        quizzes.push(quiz_model);
        // quiz_model.questions = quiz.questions;
        // quizzes.append(quiz_model);
    }

    let menu_model = RinfMenuModel {
        lessons,
        quizzes
        // id_head: menu_data_object.id_head,
    };

    // Use Some to wrap the MenuModel in an Option
    Some(menu_model)
}

/// Creates a `MenuDataObject` from `MenuModel`
/// @author Hans Duran
fn deserialize_menu_model(menu_model: RinfMenuModel) -> Option<MenuDataObject>{

    let mut lessons: Vec<Lesson> = Vec::new();

    let len = menu_model.lessons.len() - 1;
    for i in 0..len {
        let mut texts: Vec<TextFile> = Vec::new();
        for source in menu_model.lessons[i].source.clone().unwrap().texts {
            texts.push(TextFile {
                title: source.title,
                content: source.content,
            });
        }		
        let temp_lesson = Lesson {
            id: menu_model.lessons[i].id.clone(),
            title: menu_model.lessons[i].title.clone(),
            target_path: menu_model.lessons[i].location.clone(),
            // sources: Sources {
            //     source_files: menu_model.lessons[i].source.clone().unwrap().files,
            //     source_urls: menu_model.lessons[i].source.clone().unwrap().urls,
            //     source_texts: texts.clone(),
            // },
        };
        lessons.push(temp_lesson.clone());
    }

    Some(MenuDataObject {
        lessons_data_object: LessonsDataObject { lessons },
        quizzes_data_object: QuizzesDataObject { quizzes: todo!() },
        // id_head: 0
    })
}

fn load_menu_data_from_file(file_path: &str) -> Option<MenuDataObject> {
    // Open config.json file
    let mut file = match File::open(file_path) {
        Ok(output) => output,
        Err(err) => {
            crate::debug_print!("Error: {:?}", err);
            return None;
        },
    };

    // Read the file content into a string
    let mut json_content = String::new();
    match file.read_to_string(&mut json_content) {
        Ok(_) => {},
        Err(err) => {
            crate::debug_print!("Error: {:?}", err);
            return None;
        },
    };

    // Deserialize the JSON content into a MenuDataObject
    let root: Root = match serde_json::from_str(&json_content) {
        Ok(output) => output,
        Err(err) => {
            crate::debug_print!("Error: {:?}", err);
            return None;
        },
    };

    Some(root.menu_data_object)
}

fn update_lesson_file(file_path: &str, menu_data_object: &mut MenuDataObject, lesson_model: RinfLessonModel) -> std::io::Result<()> {
    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(file_path)
        .expect("Failed to open file"); // Open file

    for lesson_data_object in &mut menu_data_object.lessons_data_object.lessons { // Find ID
        if lesson_data_object.id == lesson_model.id {
            *lesson_data_object = rinf_lesson_model_to_lesson(lesson_model); // Update lesson
            break;
        }
    }

    // JSONify the struct and write to config.json
    let root = Root {
        menu_data_object: menu_data_object.clone()
    };

    let serialized_root = serde_json::to_string_pretty(&root).unwrap();

    // Write to config.json
    
    file.write_all(serialized_root.as_bytes())
    // ?: How to edit a textfile using serde or std::filestream? (delete or update)
    // Serialize `MenuDataObject` to file (serde)
    // Edit config.json
}

fn update_quiz_file(file_path: &str, mdo: &mut MenuDataObject, quiz_model: RinfQuizModel) -> std::io::Result<()> {
    // Open file
    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(file_path).expect("Failed to open file");

    // Find ID
    for temp_quiz_do in &mut mdo.quizzes_data_object.quizzes {
        if temp_quiz_do.id  == quiz_model.id {
            *temp_quiz_do = rinf_quiz_model_to_quiz(quiz_model);
            break;
        }
    }

    let root = Root {
        menu_data_object: mdo.clone()
    };

    let serialized_root = serde_json::to_string_pretty(&root).unwrap();

    file.write_all(serialized_root.as_bytes())
}

fn delete_lesson_file(file_path: &str, menu_data_object: &mut MenuDataObject, id: u32) -> std::io::Result<()> {

    let lessons = &mut menu_data_object.lessons_data_object.lessons;

    if let Some(index) = lessons.iter_mut().position(|lesson| lesson.id == id) {
        match lessons.get(index) {
            Some(lesson) => {
                // !!! warning this can delete your folders without confirmation
                let _ = remove_dir_all(lesson.target_path.clone());
            },
            None => {
                crate::debug_print!("Error: Failed to delete directory");
            },
        }

        // remove the lesson from vec
        lessons.remove(index);
    }

    let root = Root {
        menu_data_object: menu_data_object.clone(),
    };

    // edit config.json
    let serialized_root = serde_json::to_string_pretty(&root).unwrap();

    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(file_path)
        .expect("Failed to open file");

    file.write_all(serialized_root.as_bytes())
}

fn delete_quiz_file(file_path: &str, menu_data_object: &mut MenuDataObject, id: u32) -> std::io::Result<()> {

    let quizzes = &mut menu_data_object.quizzes_data_object.quizzes;

    if let Some(index) = quizzes.iter_mut().position(|quiz| quiz.id == id) {
        quizzes.remove(index);
    }

    let root = Root {
        menu_data_object: menu_data_object.clone(),
    };

    let serialized_root = serde_json::to_string_pretty(&root).unwrap();

    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(file_path)
        .expect("Failed to open file");

    file.write_all(serialized_root.as_bytes())
}

/// Creates a `LessonModel` from `Lesson`
fn rinf_lesson_model_to_lesson(lesson_model: RinfLessonModel) -> Lesson {
    let lm = lesson_model.clone(); // need to clone because of partial move
    let mut texts: Vec<TextFile> = Vec::new();
    for source in lesson_model.source.unwrap().texts {
        texts.push(TextFile {
            title: source.title,
            content: source.content,
        })
    }
    Lesson {
        id: lesson_model.id,
        title: lesson_model.title,
        target_path: lesson_model.location,
        // sources: Sources {
        //     source_files: lm.clone().source.unwrap().files,
        //     source_urls: lm.clone().source.unwrap().urls,
        //     source_texts: texts,
        // }
    }
}

fn rinf_quiz_model_to_quiz(quiz_model: RinfQuizModel) -> Quiz {

    let mut questions: Vec<Question> = Vec::new();
    let mut source_texts = Vec::new();

    let sources_clone = quiz_model.sources.clone();

    for text in sources_clone.unwrap().texts.clone() {
        source_texts.push(TextFile {
            title: text.title,
            content: text.content,
        })
    }

    let sources = Sources {
        source_files: quiz_model.sources.clone().unwrap().files,
        source_urls: quiz_model.sources.unwrap().urls,
        source_texts
    };

    for question_model in quiz_model.questions {
        match question_model.question_type {
            Some(question) => {
                match question {
                    MenuQuestionType::Identification(question_type_model) => {
                        questions.push(Question::Identification(IdentificationQuestion {
                            question: question_model.question,
                            answer: question_type_model.answer,
                        }));
                    }
                    MenuQuestionType::MultipleChoice(question_type_model) => {
                        let mut choices: Vec<Choice> = Vec::new();
                        for choice_model in question_type_model.choices {
                            choices.push(Choice {
                                content: choice_model.content,
                                is_correct: choice_model.is_correct,
                            });
                        }
                        questions.push(Question::MultipleChoice(MultipleChoiceQuestion {
                            question: question_model.question,
                            choices,
                        }));
                    }
                }
            }
            None => {}
        }
    }

    Quiz {
        id: quiz_model.id,
        title: quiz_model.title,
        // quiz_type: 1,
        target_path: quiz_model.location,
        questions,
        sources,
    }
}
