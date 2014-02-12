CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ,
  question_id INTEGER NOT NULL REFERENCES questions(id)
);

CREATE TABLE replies (
	id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL REFERENCES questions(id) ,
  parent_reply INTEGER REFERENCES replies(id),
	author_id INTEGER NOT NULL REFERENCES users(id) ,
	body TEXT NOT NULL
);

CREATE TABLE question_likes (
	id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ,
  question_id INTEGER NOT NULL REFERENCES questions(id)
);

CREATE TABLE tags (
	id INTEGER PRIMARY KEY,
	body TEXT NOT NULL
);

CREATE TABLE question_tags(
	id INTEGER PRIMARY KEY,
	question_id INTEGER NOT NULL REFERENCES questions(id),
	tag_id INTEGER NOT NULL REFERENCES tags(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Ben',
	  'Smith'
	),
  ('Rob',
	  'Andrews'
	),
  ('Ned',
	  'Ruggeri'
  );

INSERT INTO
	questions(title, body, author_id)
VALUES
  ("u wot",
	  "y u do like that",
    (SELECT id FROM users WHERE fname = 'Ben' AND lname = 'Smith')
	),
  ("how do you SQL?",
	  "seriously how do you do it",
    (SELECT id FROM users WHERE fname = 'Rob' AND lname = 'Andrews')
	),
	("disregard",
	  "accidentally entered question twice",
	  (SELECT id FROM users WHERE fname = 'Ben' AND lname = 'Smith')
  );

INSERT INTO
	question_followers(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Rob' AND lname = 'Andrews'),
    (SELECT id FROM questions WHERE title = "how do you SQL?")
	),
  ((SELECT id FROM users WHERE fname = 'Ben' AND lname = 'Smith'),
    (SELECT id FROM questions WHERE title = "how do you SQL?")
	),
  ((SELECT id FROM users WHERE fname = 'Ned' AND lname = 'Ruggeri'),
    (SELECT id FROM questions WHERE title = "how do you SQL?")
	),
  ((SELECT id FROM users WHERE fname = 'Ben' AND lname = 'Smith'),
    (SELECT id FROM questions WHERE title = "disregard")
	);

INSERT INTO
  replies(question_id, author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = "how do you SQL?"),
    (SELECT id FROM users WHERE fname = 'Ned' AND lname = 'Ruggeri'),
		"Very carefully!  :D"
	),

	((SELECT id FROM questions WHERE title = "disregard"),
    (SELECT id FROM users WHERE fname = 'Ben' AND lname = 'Smith'),
		"wait whoops"
	);

INSERT INTO
  replies(question_id, author_id, body, parent_reply)
VALUES
	((SELECT id FROM questions WHERE title = "how do you SQL?"),
  	(SELECT id FROM users WHERE fname = 'Rob' AND lname = 'Andrews'),
		":\",
	(SELECT id FROM replies WHERE question_id =
	  (SELECT id FROM questions WHERE title = "how do you SQL?")
		AND body = "Very carefully!  :D")
	);

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Ben' AND lname = 'Smith'),
    (SELECT id FROM questions WHERE title = "disregard")
	),
	((SELECT id FROM users WHERE fname = 'Ben' AND lname = 'Smith'),
    (SELECT id FROM questions WHERE title = "how do you SQL?")
	),
  ((SELECT id FROM users WHERE fname = 'Ned' AND lname = 'Ruggeri'),
    (SELECT id FROM questions WHERE title = "how do you SQL?")
	);

INSERT INTO
	tags(body)
VALUES
  ("SQL"), ("wat"), ("ruby"), ("what a jerk");

INSERT INTO
	question_tags(question_id, tag_id)
VALUES
  (1, 3), (2, 1), (2, 4), (3, 2), (3, 4);