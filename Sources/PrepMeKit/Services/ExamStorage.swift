import UIKit

class ExamStorage {
    
    static let shared = ExamStorage()
    
    let exams: [ExamSection: [Exam]]
    let questions: [Exam.ID: [Question]]
    
    var isThereOnlyOneExam: Bool {
        return exams.count == 1 && exams.first?.value.count == 1
    }
    
    private init() {
        var exams = [ExamSection: [Exam]]()
        var questions = [Exam.ID: [Question]]()
        
        let jsonDecoder = JSONDecoder()
        let bundle = Bundle.main
        let subdirectory = "Exams"
        
        let examSectionURLs = bundle.urls(forResourcesWithExtension: "json", subdirectory: subdirectory) ?? []
        for examSectionURL in examSectionURLs {
            let section = ExamSection(name: examSectionURL.deletingPathExtension().lastPathComponent)
            guard
                let data = try? Data(contentsOf: examSectionURL),
                let sectionExams = try? jsonDecoder.decode([Exam].self, from: data)
            else {
                continue
            }
            exams[section] = sectionExams
            
            for exam in sectionExams {
                guard
                    let url = bundle.url(forResource: exam.fileName, withExtension: nil, subdirectory: subdirectory + "/" + section.name),
                    let data = try? Data(contentsOf: url),
                    let examQuestions = try? JSONDecoder().decode([Question].self, from: data)
                else {
                    continue
                }
                questions[exam.id] = examQuestions
            }
        }
        
        self.exams = exams
        self.questions = questions
    }
    
    func getExam(id: Exam.ID?) -> Exam? {
        return exams.flatMap(\.value).first(where: { $0.id == id })
    }
    
}
