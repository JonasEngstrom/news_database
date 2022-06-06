#!/usr/bin/env bash
sqlite3 $1 ".read news_database_setup.sql"
