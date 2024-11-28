import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

extension Todo: CustomStringConvertible {
    var description: String {
        return isCompleted ? "✅ \(title)" : "❌ \(title)"
    }
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system 
// to persist and retrieve the list of todos. 
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {
    func save(todos: [Todo]) -> () {
        let url = getDocumentsDirectory().appendingPathComponent("todo.json")
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(todos)
            try jsonData.write(to: url)
        } catch {
            print("encoding-error: \(error.localizedDescription)")   
        }
    }
    
    func load() -> [Todo]? {
        let url = getDocumentsDirectory().appendingPathComponent("todo.json")
        do {
            let jsonData = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            let todos = try jsonDecoder.decode([Todo].self, from: jsonData)
            return todos
        } catch {
            print("decoding-error: \(error.localizedDescription)")   
        }
        return nil
    }

    // this method ref: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    func getDocumentsDirectory() -> URL {
         // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session. 
// This won't retain todos across different app launches, 
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    private var cachedTodos: [Todo] = []
    
    func save(todos: [Todo]) -> () {
        self.cachedTodos.removeAll()
        self.cachedTodos.append(contentsOf: todos)
    }

    func load() -> [Todo]? {
        return cachedTodos.isEmpty ? nil : cachedTodos
    }
}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)` 
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodoManager {
    private let cache: Cache
    private var cachedTodos: [Todo]

    init(cache: Cache) {
        self.cache = cache
        self.cachedTodos = cache.load() ?? []
    }

    func listTodos() {
        if cachedTodos.isEmpty {
            print("\nLooks like there are no todos at the moment!\n")
        } else {
            for(index, todo) in cachedTodos.enumerated() {
                print(" \(index + 1). \(todo)")
            }
        }
    }

    func addTodo(with title: String) {
        let newTodo = Todo(id: UUID(), title: title, isCompleted: false)
        self.cachedTodos.append(newTodo)
        self.cache.save(todos: self.cachedTodos)
    }

    func toggleCompletion(forTodoAtIndex index: Int) {
        if(self.cachedTodos.isEmpty) {
            print("\nLooks like there are no todos at the moment! Add one before trying to toggle\n")
        } else if(0 < index && index <= self.cachedTodos.count) {
            self.cachedTodos[index - 1].isCompleted.toggle()
            self.cache.save(todos: self.cachedTodos)
            print("🔄 Todo successfully toggled!\n📝 Your Todos:")
            self.listTodos()
        } else {
            print("\nPlease enter a valid number!\n")
        }
    }

    func deleteTodo(atIndex index: Int) {
        if(self.cachedTodos.isEmpty) {
            print("\nLooks like there are no todos at the moment! Add one before trying to delete\n")
        } else if(0 < index && index <= self.cachedTodos.count) {
            self.cachedTodos.remove(at: index - 1)
            self.cache.save(todos: self.cachedTodos)
            print("Todo successfully deleted!\n📝 Your Todos:")
            self.listTodos()
        } else {
            print("\nPlease enter a valid number!\n")
        }
    }
}


// * The `App` class should have a `func run()` method, this method should perpetually 
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases 
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {
    private var counterFlag: Bool
    private let todoManager: TodoManager
    
    init() {
        self.counterFlag = true
        self.todoManager = TodoManager(cache: JSONFileManagerCache())
    }

    enum Command: String {
        case add
        case list
        case toggle
        case delete
        case exit
    }

    public func run() {
        while(counterFlag) {
            print("What would you like to do? (add, list, toggle, delete, exit):")
            if let userCommand = readLine(), let currentCommand = Command(rawValue: userCommand) {
                switch currentCommand {
                    case .add: 
                        print("\nEnter todo title:")
                        if let userTitle = readLine() {
                            todoManager.addTodo(with: userTitle)
                            print("📌 Todo added!")
                        }
                    case .list:
                        print("📝 Your Todos:")
                        todoManager.listTodos()
                    case .toggle: 
                        print("\nEnter the number of todo to toggle")
                        if let userIntString = readLine(), let userInt = Int(userIntString) {
                            todoManager.toggleCompletion(forTodoAtIndex: userInt)
                        }
                    case .delete: 
                        print("\nEnter the number of todo to delete")
                        if let userIntString = readLine(), let userInt = Int(userIntString) {
                            todoManager.deleteTodo(atIndex: userInt)
                        }
                    case .exit:
                        print("\n🗂️ Saving Todos into the file-dir. Exiting ..\n")
                        //self.todoManager.saveToFileOnExit()
                        counterFlag = false
                }
            } else {
                print("\nInvalid command given, try again!\n")
            }
        }
    }
}


// TODO: Write code to set up and run the app.
print("🌟 Welcome to Todo CLI! 🌟\n")
App().run()
