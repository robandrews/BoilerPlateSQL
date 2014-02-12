require 'rspec'
require 'QuestionsDatabase'
$FILEPATH = "./lib/questions_test.db"

#Database initialized by import_db.sql - look there for appropriate values
describe "User" do
  system("rm ./lib/questions_test.db")
  system("cat ./lib/import_db.sql | sqlite3 lib/questions_test.db")

  it "makes a list of most popular questions for a given tag" do
    jerk_tag = Tag.new( { "id" => 4, "body" => "what a jerk" } )
    questions = jerk_tag.most_popular_questions(2)
    expect(questions).to be_a(Array)
    expect(questions.first).to be_a(Question)
    expect(questions.length).to be(2)
    expect(questions.first.id).to eq(2)
    expect(questions.last.id).to eq(3)
  end

  it "makes a list of most popular tags" do
    tags = Tag.most_popular(2)
    expect(tags).to be_a(Array)
    expect(tags.first).to be_a(Tag)
    expect(tags.length).to be(2)
    expect(tags.first.id).to eq(4)
    expect(tags[1].id).to eq(1)
  end
end