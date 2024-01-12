from dotenv import load_dotenv
import os

from openai import OpenAI

load_dotenv()
client = OpenAI(api_key = os.getenv("API_KEY"))

def generate_quiz(source):

    prompt = "Make a JSON for a quiz with " + source

    response = client.chat.completions.create(
        model = "gpt-3.5-turbo",
        messages = [
            {"role": "system", "content": "You are a system that generates quizzes."},
            {"role": "user", "content": prompt}
        ]
    )

    return source + "JSON Text"