CREATE TABLE hopes
(
  id SERIAL PRIMARY KEY,
  "desc" VARCHAR(256) NOT NULL,
  "date" VARCHAR(128),
  bumpCount INT
);

CREATE PROCEDURE avg_bump_count_func(OUT ans DOUBLE)
  LANGUAGE javascript PARAMETER STYLE variables AS $$
    function avg_bump_count() {
      var conn = java.sql.DriverManager.getConnection("jdbc:default:connection", "test", "");
      var ps = conn.prepareStatement("SELECT avg(bumpcount) FROM hopes");
      var rs = ps.executeQuery();
      rs.next();
      return rs.getDouble(1);
    }
    ans = avg_bump_count();
  $$;
