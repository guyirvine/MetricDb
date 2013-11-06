CREATE SEQUENCE metric_seq;
CREATE SEQUENCE value_seq;

CREATE TABLE metric_tbl (
  id BIGINT NOT NULL DEFAULT NEXTVAL( 'metric_seq' ),
  name VARCHAR(255) NOT NULL,
  PRIMARY KEY ( id ),
UNIQUE ( name ) );

CREATE TABLE value_tbl (
    id BIGINT NOT NULL DEFAULT NEXTVAL( 'value_seq' ),
    metric_id BIGINT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    value NUMERIC,
    PRIMARY KEY ( id ),
    FOREIGN KEY ( metric_id ) REFERENCES metric_tbl (id)
);
