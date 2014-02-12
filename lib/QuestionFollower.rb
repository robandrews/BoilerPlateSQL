class QuestionFollower
  attr_reader :id, :user_id, :question_id

  def self.find_by_id(id)
    query = <<-SQL
    SELECT
      *
    FROM
      question_followers
    WHERE
      id = ?
    SQL
    QuestionFollower.new(QuestionsDatabase.instance.execute(query, id)[0])
  end

  def self.followers_for_question_id(id)
    followers = []
    query = <<-SQL
    SELECT
      users.id, users.fname, users.lname
    FROM
      users JOIN question_followers
        ON users.id = question_followers.user_id
    WHERE
      question_id = ?
    SQL

    raw_followers = QuestionsDatabase.instance.execute(query, id)
    raw_followers.each do |entry|
      followers << User.new(entry)
    end
    followers
  end

  def self.followed_questions_for_user_id(id)
    questions = []
    query = <<-SQL
    SELECT
      questions.id, questions.title, questions.body, questions.author_id
    FROM
      question_followers JOIN questions
        ON questions.id = question_followers.question_id
    WHERE
      user_id = ?
    SQL

    raw_questions = QuestionsDatabase.instance.execute(query, id)
    raw_questions.each do |entry|
      questions << Question.new(entry)
    end
    questions
  end

  def initialize(options={})
    @id, @user_id, @question_id =
      options.values_at('id', 'user_id', 'question_id')
  end

  def self.most_followed_questions(n)
    questions = []

    query = <<-SQL
    SELECT
    questions.id, author_id, title, body
    FROM
    questions
    JOIN
    question_followers
    ON
    questions.id = question_followers.question_id
    GROUP BY
    question_id
    ORDER BY
    COUNT(user_id) DESC
    LIMIT ?
    SQL

    raw_questions = QuestionsDatabase.instance.execute(query, n)
    raw_questions.each do |entry|
      questions << Question.new(entry)
    end
    questions
  end
end