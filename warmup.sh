#!/bin/bash
set -e

# Gradle build of backend
cd backend
./gradlew :build -x :test

# Build frontend
cd ..
cd frontend
npm install --force

cd ..