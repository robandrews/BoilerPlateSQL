class QuestionLike
  attr_reader :id, :user_id, :question_id

  def self.find_by_id(id)
    query = <<-SQL
    SELECT
      *
    FROM
      question_likes
    WHERE
      id = ?
    SQL
    QuestionLike.new(QuestionsDatabase.instance.execute(query, id)[0])
  end

  def self.num_likes_for_question_id(id)
    query = <<-SQL
    SELECT
    COUNT(users.id) likes
    FROM
      users INNER JOIN question_likes
        ON users.id = question_likes.user_id
    WHERE
      question_id = ?
    SQL

    QuestionsDatabase.instance.execute(query, id)[0]["likes"]
  end

  def self.liked_questions_for_user_id(id)
    questions = []
    query = <<-SQL
    SELECT
      questions.id, questions.title, questions.body, questions.author_id
    FROM
      question_likes JOIN questions
        ON questions.id = question_likes.question_id
    WHERE
      user_id = ?
    SQL

    raw_questions = QuestionsDatabase.instance.execute(query, id)
    raw_questions.each do |entry|
      questions << Question.new(entry)
    end
    questions
  end

  def self.likers_for_question_id(id)

    likers = []
    query = <<-SQL
    SELECT
      users.id, users.fname, users.lname
    FROM
      users JOIN question_likes
        ON users.id = question_likes.user_id
    WHERE
      question_id = ?
    SQL

    raw_likers = QuestionsDatabase.instance.execute(query, id)
    raw_likers.each do |entry|
      likers << User.new(entry)
    end
    likers
  end

  def initialize(options={})
    @id, @user_id, @question_id =
      options.values_at('id', 'user_id', 'question_id')
  end

  def self.most_liked_questions(n)
    questions = []

    query = <<-SQL
    SELECT
    questions.id, author_id, title, body
    FROM
    questions
    JOIN
    question_likes
    ON
    questions.id = question_likes.question_id
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