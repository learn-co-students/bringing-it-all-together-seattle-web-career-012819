class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash_info)
    @name = hash_info[:name]
    @breed = hash_info[:breed]
    @id = nil
  end

  def self.create_table()
    sql = <<-sql
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    sql

    DB[:conn].execute(sql)
  end

  def self.drop_table()
    sql = <<-sql
      DROP TABLE dogs;
    sql

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-sql
      INSERT INTO dogs (name, breed)
      VALUES (?,?);
    sql

    DB[:conn].execute(sql, self.name, self.breed)
    rows = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")
    @id = rows[0][0]
    self
  end

  def self.create(hash_info)
    new_dog = Dog.new(hash_info)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-sql
      SELECT * FROM dogs
      WHERE id = ?;
    sql

    DB[:conn].execute(sql, id)
    rows = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")
    dog_hash = {name: rows[1], breed: rows[2]}
    new_dog = Dog.new(dog_hash)
    new_dog.id = rows[0][0]
    new_dog
  end

  def self.find_or_create_by(hash_info)
    sql = <<-sql
      SELECT * FROM dogs
      WHERE name = ? AND
      breed = ?;
    sql

    results = DB[:conn].execute(sql, hash_info[:name], hash_info[:breed])
    if !results.empty?
      rows = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")
      dog_hash = {name: rows[1], breed: rows[2]}
      new_dog = Dog.new(dog_hash)
      new_dog.id = rows[0][0]
      new_dog
    else
      create(hash_info)
    end
  end

  def self.new_from_db(rows)
    new_dog = Dog.new({name: rows[1], breed: rows[2]})
    new_dog.id = rows[0]
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-sql
      SELECT * FROM dogs
      WHERE name = ? ;
    sql

    rows = DB[:conn].execute(sql, name)
    dog_hash = {name: rows[0][1], breed: rows[0][2]}
    new_dog = Dog.new(dog_hash)
    new_dog.id = rows[0][0]
    new_dog
  end

  def update
    sql = <<-sql
      UPDATE dogs
      SET name = ? ,
      breed = ?;
    sql
    DB[:conn].execute(sql, self.name, self.breed)
  end

end
