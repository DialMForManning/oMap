# oMap - Object-relational mapping using SQL

oMap connects classes to SQL based relational database tables. The library provides a base class (SQLObject) that, when subclassed, establishes a mapped relationship between the new class and an existing table in the database. Classes inheriting from SQLObject, referred to as **models**, can have **associations** defined on them which connect them to other models.

When defining associations, oMap will assume default table names, class names, and column names for primary and foreign keys based on traditional Ruby on Rails naming conventions. These names can also be defined explicitly by the user in cases where non-conventional names are used.

Overview of major features:

- Automated mapping between model classes and tables, as well as instance attributes and columns.

```
class Book < SQLObject
end
```
The Book model class is automatically mapped to the table named "books." Consider a books table that looks like this:

```
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

```
belongs_to :reader
belongs_to :library
```

This will assume the associated table names are "readers" and "libraries", the associated foreign keys are "reader_id" and "library_id", and the model names are 'Reader' and 'Library'. These associations can be defined more explicitly. For example:
```
belongs_to :reader
  class_name: 'Reader',
  primary_key: :id,
  foreign_key: :reader_id
```

`::make_helpers!` will create helper methods for getting related models through their associations. In this example, instances of Book will now have `#reader` and `#library`.

- `#insert`, `#update`, and `#save` can be called on model instances to create or update table entries.

- Models inheriting from SQLObject are also searchable using the Model::where function, which is passed an options hash mapping column names to query terms. For example, the following command:

```
Reader.where(name: 'Atrus')
```

would execute the following SQL query

```
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
