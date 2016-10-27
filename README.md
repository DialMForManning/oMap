# oMap - Object-relational mapping using SQL

oMap connects classes to SQL based relational database tables. The library provides a base class (SQLObject) that, when subclassed, establishes a mapped relationship between the new class and an existing table in the database. Classes inheriting from SQLObject, referred to as **models**, can have **associations** defined on them which connect them to other models.

When defining associations, oMap will assume default table names, class names, and column names for primary and foreign keys based on traditional Ruby on Rails naming conventions. These names can also be defined explicitly by the user in cases where non-conventional names are used.

Overview of major features:

- Automated mapping between model classes and tables, as well as instance attributes and columns.

```Ruby
class Book < SQLObject
end
```
The Book model class is automatically mapped to the table named "books." Consider a books table that looks like this:

```Ruby
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  reader_id INTEGER,
  library_id INTEGER,

  FOREIGN KEY(reader_id) REFERENCES reader(id)
  FOREIGN KEY(library_id) REFERENCES library(id)
);
```
Inheriting from SQLObject will also define the following accessors: `Book#title`, `Book#title=`, `Book#reader_id`, `Book#reader_id=`, `Book#library_id`, `#Book#library_id=`.

- Associations between other model classes are defined by simple class methods.

```Ruby
belongs_to :reader
belongs_to :library
```

This will assume the associated table names are "readers" and "libraries", the associated foreign keys are "reader_id" and "library_id", and the model names are 'Reader' and 'Library'. These associations can be defined more explicitly. For example:
```Ruby
belongs_to :reader
  class_name: 'Reader',
  primary_key: :id,
  foreign_key: :reader_id
```

`::make_helpers!` will create helper methods for getting related models through their associations. In this example, instances of Book will now have `#reader` and `#library`.

- `#insert`, `#update`, and `#save` can be called on model instances to create or update table entries.

- Models inheriting from SQLObject are also searchable using the Model::where function, which is passed an options hash mapping column names to query terms. For example, the following command:

```Ruby
Reader.where(name: 'Atrus')
```

would execute the following SQL query

```SQL
SELECT
  *
FROM
  readers
WHERE
  name = Atrus
```

and return an array of Reader instances that satisfy the query terms.

## Demonstration

A 'demo.rb' file is included in this repository. Upon loading 'demo.rb' using a REPL such as pry, small example database defined in 'books.sql' will be created alongside Book, Reader, and Library models and their associations.

After calling `load 'demo.rb'` you can check out what the sample database contains by calling `Book.all`, `Reader.all`, and `Library.all`. The sample database is pretty small so don't worry about overflowing your screen with results. For example, `Book.all` should return:

```
[#<Book:0x007fc101af8ad8
  @attributes={:id=>1, :title=>"Stoneship", :reader_id=>1, :library_id=>1}>,
 #<Book:0x007fc101af85b0
  @attributes={:id=>2, :title=>"Selentic", :reader_id=>1, :library_id=>1}>,
 #<Book:0x007fc101af8470
  @attributes={:id=>3, :title=>"Haven", :reader_id=>4, :library_id=>1}>,
 #<Book:0x007fc101af81a0
  @attributes={:id=>4, :title=>"233rd Age", :reader_id=>3, :library_id=>2}>,
 #<Book:0x007fc101af8060
  @attributes={:id=>5, :title=>"Spire", :reader_id=>nil, :library_id=>nil}>]
```

If you know the id, the `::find` method will find the entry with that id in the database and return the appropriate object. For example `Book.find(3)` will return:

```
#<Book:0x007fc1030a8888 @attributes={:id=>3, :title=>"Haven", :reader_id=>4, :library_id=>1}>
```

You can create a new book object by initializing it and passing a hash containing all the necessary attributes, for example:

```Ruby
book = Book.new(title: 'Channelwood', reader_id: 2, library_id: 1)
```

Your new instance `book` can now be saved to the database by calling either `book.insert` or `book.save`. If `book` was instantiated by specifying a primary key that already existed in the database, `book.update` could be called to update the associated columns in the database entry with any attributes `book` was instantiated with.

Book, Library, and Reader are also searchable using `#where`, which is passed an options hash of attributes. All records where all passed attributes match the corresponding columns will be returned. For example:

```Ruby
Book.where(reader_id: 1)
```
returns:

```
[#<Book:0x007fc101af8ad8
  @attributes={:id=>1, :title=>"Stoneship", :reader_id=>1, :library_id=>1}>,
 #<Book:0x007fc101af85b0
  @attributes={:id=>2, :title=>"Selentic", :reader_id=>1, :library_id=>1}>]
```

Book, Reader, and Library will also have associations defined on it. For example, calling `Library.find(1).books` will return:

```
[#<Book:0x007fc10110b0e8 @attributes={:id=>1, :title=>"Stoneship", :reader_id=>1, :library_id=>1}>,
 #<Book:0x007fc10110ae40 @attributes={:id=>2, :title=>"Selentic", :reader_id=>1, :library_id=>1}>,
 #<Book:0x007fc10110aaf8 @attributes={:id=>3, :title=>"Haven", :reader_id=>4, :library_id=>1}>,
 #<Book:0x007fc10110a7d8 @attributes={:id=>6, :title=>"Channelwood", :reader_id=>2, :library_id=>1}>]
```

Note, 'Channelwood' would only exists here because we added to the database earlier in the demo. It will not be in the database as seeded so your results may not include it.
