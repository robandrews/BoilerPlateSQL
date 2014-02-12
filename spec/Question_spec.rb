require 'rspec'
require 'questions_database'
$FILEPATH =  "./db/questions_test.db"

#Database initialized by import_db.sql - look there for appropriate values
describe "User" do
  system("rm ./lib/questions_test.db")
  system("cat ./lib/import_db.sql | sqlite3 db/questions_test.db")

  context "finding/creating questions" do
    it "can construct question by id" do
      expect(Question.find_by_id(1)).to be_a(Question)
    end

    it "constructs the correct question by id" do
      expect(Question.find_by_id(2).title).to eq("how do you SQL?")
    end

    it "can construct an array of questions by author id" do
      returned_questions = Question.find_by_author_id(1)
      expect(returned_questions).to be_a(Array)
      expect(returned_questions.first).to be_a(Question)
    end

    it "constructs the correct questions by author id" do
      expect(Question.find_by_author_id(1).length).to eq(2)
      expect([1, 3]).to include(Question.find_by_author_id(1).first.id)
      expect([1, 3]).to include(Question.find_by_author_id(1).last.id)
    end

  end
  context "when a question is already defined" do
    subject(:howsql) { Question.find_by_id(2) }

    it "returns its author" do
      expect(howsql.author).to be_a(User)
      expect(howsql.author.fname).to eq("Rob")
    end

    it "finds replies to itself" do
      expect(howsql.replies).to be_a(Array)
      expect(howsql.replies.first).to be_a(Reply)
      expect(howsql.replies.length).to eq(2)
      expect([1, 3]).to include(howsql.replies.first.id)
      expect([1, 3]).to include(howsql.replies.last.id)
    end

    it "finds its followers" do
      expect(howsql.followers).to be_a(Array)
      expect(howsql.followers.first).to be_a(User)
      expect(howsql.followers.length).to eq(3)
      expect([1, 2, 3]).to include(howsql.followers.first.id)
      expect([1, 2, 3]).to include(howsql.followers[1].id)
      expect([1, 2, 3]).to include(howsql.followers.last.id)
    end

    it "returns array of users that like it" do
      #it's like a dating service!  :D
      expect(howsql.likers).to be_a(Array)
      expect(howsql.likers.first).to be_a(User)
    end

    it "finds the correct users that like it" do
      expect(howsql.likers.length).to eq(2)
      expect([1, 3]).to include(howsql.likers.first.id)
      expect([1, 3]).to include(howsql.likers.last.id)
    end

    it "finds its number of likes" do
      expect(howsql.num_likes).to eq(2)
    end

    it "makes a list of most-followed questions" do
      questions = Question.most_followed(2)
      expect(questions).to be_a(Array)
      expect(questions.first).to be_a(Question)
      expect(questions.first.id).to eq(2)
      expect(questions.last.id).to eq(3)
    end

    it "makes a list of most-liked questions" do
      questions = Question.most_liked(2)
      expect(questions).to be_a(Array)
      expect(questions.first).to be_a(Question)
      expect(questions.first.id).to eq(2)
      expect(questions.last.id).to eq(3)
    end
  end

  context "saving a new entry" do
    new_question = nil
    before(:each) do
      new_question = Question.new({"id" => nil, "author_id" => 2, "title" => "test", "body" => "ing"})
    end
    it "can save to database" do
      start_length = QuestionsDatabase.instance.execute("SELECT * FROM questions").length
      new_question.save
      end_length = QuestionsDatabase.instance.execute("SELECT * FROM questions").length
      expect(end_length).to eq(start_length + 1)
    end

    it "updates id after saving" do
      expect(new_question.id).to be(nil)
      new_question.save
      expect(new_question.id).to_not be(nil)
    end

    it "updates existing entry" do
      new_question.save
      id = new_question.id
      expect(Question.find_by_id(id).title).to eq("test")
      new_question.title = "test2"
      new_question.save
      expect(Question.find_by_id(id).title).to eq("test2")
      expect(new_question.id).to eq(id)
    end
  end
end
