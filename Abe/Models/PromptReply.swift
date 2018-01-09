
import Foundation
import RealmSwift

class PromptReply: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var user: User?
    @objc dynamic var promptId: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var visibility: String = "all"
    @objc dynamic var createdAt = Date()
    let scores = List<ReplyScore>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(user: User,
                     promptId: String,
                     body: String,
                     visibility: String = "all") {
        self.init()
        self.user = user
        self.promptId = promptId
        self.body = body
        self.visibility = visibility
    }
    
    var value: [String: Any] {
        return ["id": UUID().uuidString,
                "promptId": promptId,
                "visibility": visibility,
                "body": body]
    }
    
    func isAuthorInCurrentUserContacts(currentUser: User) -> Bool {
        return self.user!.id != currentUser.id
            &&
            self.user!.allNumbersFromContacts()
                .contains(currentUser.phoneNumber)
    }
    
    func fetchCastedScoreIfExists(for userId: String) -> (score: ReplyScore?, reply: PromptReply) {
        let score = self.scores
            .filter(NSPredicate(format: "userId = %@", userId)).first
        return (score, self)
    }
    
    func percentageOfVotesCastesFor(scoreValue: Int) -> Double {
        guard self.scores.count > 0 else { return 0.0 }
        let numberOfVotesForScore = self.scores
            .filter(NSPredicate(format: "score == %i", scoreValue))
        guard numberOfVotesForScore.count > 0 else { return 0.0 }
        return (Double(numberOfVotesForScore.count) / Double(self.scores.count))
    }
    

}

class ReplyScore: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var replyId: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var score: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(userId: String, replyId: String, score: Int) {
        self.init()
        self.userId = userId
        self.replyId = replyId
        self.score = score
    }
    
    static func valueDict(user: User, replyId: String, score: String) -> [String: Any] {
        return ["userId": user.id, "replyId": replyId, "score": score]
    }
}
