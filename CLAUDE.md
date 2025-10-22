# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flask-based web application called "张飞吃豆芽" (Zhang Fei Eats Bean Sprouts) - an AI-powered article generator that integrates with Google Gemini API. It supports batch generation, automatic image insertion, custom styles, and direct Word document output.

## Development Commands

### Starting the Application

1. **macOS/Linux**:
   ```bash
   ./start.sh
   ```
   This script automatically:
   - Creates a Python virtual environment (venv)
   - Activates the virtual environment
   - Installs dependencies from requirements.txt
   - Starts the Flask application
   - Opens the browser at http://127.0.0.1:5000

2. **Windows**:
   ```bash
   start.bat
   ```
   This script:
   - Installs dependencies from requirements.txt
   - Starts the Flask application
   - Opens the browser at http://127.0.0.1:5000

3. **Manual Start**:
   ```bash
   # Create virtual environment
   python3 -m venv venv

   # Activate virtual environment
   # On macOS/Linux:
   source venv/bin/activate
   # On Windows:
   venv\Scripts\activate

   # Install dependencies
   pip install -r requirements.txt

   # Run the application
   python app.py
   ```

### Dependencies

The main dependencies are:
- Flask >= 3.0.0
- flask-cors >= 4.0.0
- google-generativeai >= 0.3.0
- python-docx >= 1.1.0
- requests >= 2.31.0
- pillow >= 10.0.0

Install with: `pip install -r requirements.txt`

### Required External Tools

- **Pandoc**: Required for converting Markdown to Word documents
  - Install on macOS: `brew install pandoc`
  - Install on Windows: Download from https://pandoc.org/installing.html

## Code Architecture

### Main Components

1. **app.py**: The main Flask application containing:
   - API endpoints for configuration, article generation, image handling
   - Integration with Google Gemini API for content generation
   - Support for multiple image sources (Unsplash, Pexels, Pixabay, ComfyUI, local)
   - Word document generation via Pandoc
   - Concurrent task processing with thread pools

2. **Frontend Structure**:
   - Templates: HTML files in the `templates/` directory
   - Static assets: CSS and JavaScript files in the `static/` directory
   - Navigation: Write, Config, and History pages

3. **Configuration**:
   - `config.json`: Main configuration file (created on first run)
   - `config.example.json`: Example configuration template

4. **Key Directories**:
   - `output/`: Generated Word documents
   - `uploads/`: User-uploaded images
   - `pic/`: Local image gallery
   - `templates/`: HTML templates
   - `static/`: CSS and JavaScript files

### Core Features

1. **Article Generation**:
   - Uses Google Gemini API to generate articles based on topics
   - Customizable prompts and model selection
   - Markdown formatting with proper structure

2. **Image Integration**:
   - Multiple image sources with priority configuration
   - ComfyUI integration for AI-generated images
   - Automatic image insertion in generated documents
   - Local image gallery support

3. **Document Output**:
   - Direct Word (.docx) document generation
   - Uses Pandoc for Markdown to Word conversion
   - Automatic cleanup of temporary files

4. **Task Management**:
   - Concurrent processing with configurable thread pool
   - Progress tracking and status monitoring
   - Retry mechanism for failed tasks

## Common Development Tasks

### Adding New API Endpoints

Add new endpoints in `app.py` using the `@app.route()` decorator. Follow the existing patterns for request handling and response formatting.

### Modifying Frontend

1. Update HTML templates in the `templates/` directory
2. Update CSS in `static/style.css`
3. Update JavaScript in the corresponding `static/*.js` files

### Configuration Changes

1. Modify default settings in `config.example.json`
2. The actual configuration is stored in `config.json` and can be updated through the web interface

### Testing Changes

1. Start the application using the development commands above
2. Access the web interface at http://127.0.0.1:5000
3. Test functionality through the UI