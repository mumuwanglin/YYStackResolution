import Foundation

class SubProcess {
    var output: String = ""
    var error: String = ""
    
    var cmd: String
    var args: [String]?
    var env: [String: String]?

    var exitCode: Int
    
    var outputHandler: ((String)->Void)?
    var errorHandler: ((String)->Void)?

    private var task: Process?
    
    init(cmd: String, args: [String]?, env: [String: String]? = nil) {
        self.cmd = cmd
        self.args = args
        self.env = env
        self.exitCode = 0
    }
    
    @discardableResult
    func run() -> Bool {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        outputPipe.fileHandleForReading.readabilityHandler = {handle in
            guard let string = String(data: handle.availableData, encoding: String.Encoding.utf8) else {
                return
            }
            self.output += string
            if let outputHandler = self.outputHandler {
                outputHandler(string)
            }
        }
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            guard let string = String(data: handle.availableData, encoding: String.Encoding.utf8) else {
                return
            }
            self.error += string
            if let errorHandler = self.errorHandler {
                errorHandler(string)
            }
        }
        
        let task = Process()
        task.launchPath = self.cmd
        task.arguments = self.args
        if let customEnv = self.env {
            var env = task.environment ?? [:]
            customEnv.forEach { (k, v) in env[k] = v }
            task.environment = env
        }
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.terminationHandler = { process in
            
        }
        
        self.task = task
        task.launch()
        task.waitUntilExit()
        
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
        
        self.exitCode = Int(task.terminationStatus)
        return (exitCode == 0)
    }
    
    func terminate() {
        self.task?.terminate()
    }
}
