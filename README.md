# Yassir

# Rick and Morty iOS Application

## Project Overview
This project is an iOS application designed to interact with the [Rick and Morty API](https://rickandmortyapi.com/) to retrieve and display a list of characters in a paginated manner. The application uses a mix of UIKit (for TableView or CollectionView) and SwiftUI for smaller views to demonstrate good coding practices, maintainability, and scalability.

## Instructions for Building and Running the Application

### Prerequisites
- **Xcode** (version 15 or later)
- **iOS Simulator** (iOS 16 or later)
- **Swift Package Manager** (SPM) for dependency management

### Dependencies
- **Kingfisher**: Used for downloading and caching images.

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <https://github.com/UgoValPrime/Yassir.git>
2. **Open the project in Xcode**:
  - Copy code
  - open Yassir.xcworkspace
  - Install dependencies using Swift Package Manager (SPM):

3. **Open Xcode**.
  - Go to File > Swift Packages > Add Package Dependency.
  - Enter the Kingfisher package URL: https://github.com/onevcat/Kingfisher.
  - Follow the prompts to install the package.
  - Build and run the project:

  - Select the target device (e.g., iOS Simulator).
  - Ensure the app is in light mode for testing.
  - Press Cmd + R to build and run the application.
### Architecture
The application follows the MVVM (Model-View-ViewModel) architecture pattern, which helps separate concerns and make the code more maintainable and testable. Below is a summary of the key components in this architecture:

Model: Represents the data of the application (e.g., characters from the API). It defines the structure of the data and provides methods for data fetching and manipulation.

View: The UI components of the app, which are responsible for presenting the data to the user. Views are managed using UIKit for complex views like TableView or CollectionView, and SwiftUI for smaller, reusable components.

ViewModel: Acts as an intermediary between the View and the Model. The ViewModel is responsible for processing the data and preparing it for display in the View. It handles any business logic, such as transforming API data, and manages user actions.

Dependency Injection
The project uses a bit of dependency injection to provide the ViewModels and services with their dependencies at runtime. This approach ensures that components are loosely coupled and easier to test.

###Challenges Encountered and Solutions
1. URL Validation
Challenge: Ensuring robust URL validation to avoid invalid URL requests.
Solution: Implemented a comprehensive URL validation method to check the URL scheme, host, and proper formation before making network requests.
2. API Data Parsing
Challenge: Handling potential issues with API data parsing and decoding.
Solution: Added thorough error handling and logging to manage and debug decoding errors effectively.
3. Testing and Mocking Dependencies
Challenge: Creating reliable and isolated unit tests for the ViewModel and services.
Solution: Utilized mock services and network managers to simulate API responses, enabling comprehensive unit testing.
Testing
Unit tests are provided to verify the functionality of the ViewModel and network service interactions.
Tests are run on the iOS Simulator in Xcode in light mode to ensure consistent visual presentation.
