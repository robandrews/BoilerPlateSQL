require 'rspec'
require 'questions_database'
$FILEPATH =  "./db/questions_test.db"

#Database initialized by import_db.sql - look there for appropriate values
describe "Reply" do
  system("rm ./db/questions_test.db")
  system("cat ./lib/import_db.sql | sqlite3 db/questions_test.db")

  context "finding/creating replies" do
    it "can construct reply by id" do
      expect(Reply.find_by_id(1)).to be_a(Reply)
    end

    it "constructs the correct reply by id" do
      expect(Reply.find_by_id(2).body).to eq("wait whoops")
    end

    it "can construct an array of replies by author id" do
      returned_replies = Reply.find_by_author_id(1)
      expect(returned_replies).to be_a(Array)
      expect(returned_replies.first).to be_a(Reply)
    end

    it "constructs the correct reply by author id" do
      expect(Reply.find_by_author_id(2)[0].id).to eq(3)
    end

    it "can construct an array of replies by question id" do
      returned_replies = Reply.find_by_question_id(2)
      expect(returned_replies).to be_a(Array)
      expect(returned_replies.first).to be_a(Reply)
    end

    it "constructs the correct replies by question id" do
      expect(Reply.find_by_question_id(2).length).to eq(2)
      expect([1,3]).to include(Reply.find_by_question_id(2).first.id)
      expect([1,3]).to include(Reply.find_by_question_id(2).last.id)
    end
  end

  context "When a reply is already defined" do
    subject(:carefully) {Reply.find_by_id(1)}

    it "returns its author" do
      expect(carefully.author).to be_a(User)
      expect(carefully.author.fname).to eq("Ned")
    end

    it "looks for the question it is a part of" do
      expect(carefully.question).to be_a(Question)
      expect(carefully.question.id).to eq(2)
    end

    it "should find child replies" do
      expect(carefully.child_replies).to be_a(Array)
      expect(carefully.child_replies.first).to be_a(Reply)
    end

    it "should find the correct child replies" do
      expect(carefully.child_replies.first.id).to eq(3)
    end

    it "should find parent replies if they exist" do
      expect(carefully.child_replies.first.parent_reply.id).to eq(carefully.id)
    end

    it "should return nil with no parent reply" do
      expect(carefully.parent_reply).to be(nil)
    end
  end

  context "saving a new entry" do
    new_reply = nil
    before(:each) do
      new_reply = Reply.new({"id" => nil, "author_id" => 2, "question_id" => 2,
        "body" => "test", "parent_reply" => 3})
    end
    it "can save to database" do
      start_length = QuestionsDatabase.instance.execute("SELECT * FROM replies").length
      new_reply.save
      end_length = QuestionsDatabase.instance.execute("SELECT * FROM replies").length
      expect(end_length).to eq(start_length + 1)
    end

    it "updates id after saving" do
      expect(new_reply.id).to be(nil)
      new_reply.save
      expect(new_reply.id).to_not be(nil)
    end

    it "updates existing entry" do
      new_reply.save
      id = new_reply.id
      expect(Reply.find_by_id(id).body).to eq("test")
      new_reply.body = "test2"
      new_reply.save
      expect(Reply.find_by_id(id).body).to eq("test2")
      expect(new_reply.id).to eq(id)
    end
  end
end