require 'rspec'
require 'QuestionsDatabase'
$FILEPATH = "./lib/questions_test.db"

#Database initialized by import_db.sql - look there for appropriate values
describe "User" do
  system("rm ./lib/questions_test.db")
  system("cat ./lib/import_db.sql | sqlite3 lib/questions_test.db")

  context "finding/creating users" do
    it "can construct user by id" do
      expect(User.find_by_id(1)).to be_a(User)
    end

    it "constructs the correct user by id" do
      expect(User.find_by_id(2).fname).to eq("Rob")
    end

    it "can construct an array of users by name" do
      returned_users = User.find_by_name('Ben', 'Smith')
      expect(returned_users).to be_a(Array)
      expect(returned_users.first).to be_a(User)
    end

    it "constructs the correct user by name" do
      expect(User.find_by_name('Rob', 'Andrews')[0].id).to eq(2)
    end
  end

  context "with a user already defined" do
    subject(:ben) { User.find_by_id(1) }

    it "can find an array of authored questions" do
      expect(ben.authored_questions).to be_a(Array)
      expect(ben.authored_questions.first).to be_a(Question)
    end

    it "finds correct questions for user" do
      expect(ben.authored_questions.length).to eq(2)
      expect([1, 3]).to include(ben.authored_questions.first.id)
      expect([1, 3]).to include(ben.authored_questions.last.id)
    end

    it "can find an array of authored replies" do
      expect(ben.authored_replies).to be_a(Array)
      expect(ben.authored_replies.first).to be_a(Reply)
    end

    it "finds correct questions for replies" do
      expect(ben.authored_replies.length).to eq(1)
      expect(ben.authored_replies.first.id).to eq(2)
    end

    it "can find an array of followed questions" do
      expect(ben.followed_questions).to be_a(Array)
      expect(ben.followed_questions.first).to be_a(Question)
    end

    it "finds correct followed questions" do
      expect(ben.followed_questions.length).to eq(2)
      expect([2, 3]).to include(ben.followed_questions.first.id)
      expect([2, 3]).to include(ben.followed_questions.last.id)
    end

    it "can find an array of liked questions" do
      expect(ben.liked_questions).to be_a(Array)
      expect(ben.liked_questions.first).to be_a(Question)
    end

    it "can find questions the user has liked" do
      expect(ben.liked_questions.length).to eq(2)
      expect([2, 3]).to include(ben.liked_questions.first.id)
      expect([2, 3]).to include(ben.liked_questions.last.id)
    end
  end

  context "saving a new entry" do
    new_user = nil
    before(:each) do
      new_user = User.new({"id" => nil, "fname" => "test", "lname" => "user"})
    end
    it "can save to database" do
      start_length = QuestionsDatabase.instance.execute("SELECT * FROM users").length
      new_user.save
      end_length = QuestionsDatabase.instance.execute("SELECT * FROM users").length
      expect(end_length).to eq(start_length + 1)
    end

    it "updates id after saving" do
      expect(new_user.id).to be(nil)
      new_user.save
      expect(new_user.id).to_not be(nil)
    end

    it "updates existing entry" do
      new_user.save
      id = new_user.id
      expect(User.find_by_id(id).fname).to eq("test")
      new_user.fname = "test2"
      new_user.save
      expect(User.find_by_id(id).fname).to eq("test2")
      expect(new_user.id).to eq(id)
    end
  end
end
