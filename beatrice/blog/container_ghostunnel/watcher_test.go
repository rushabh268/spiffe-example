/*-
 * Copyright 2015 Square Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package main

import (
	"io/ioutil"
	"os"
	"testing"
	"time"
)

func TestWatchers(t *testing.T) {
	// Setup
	tmpDir, err := ioutil.TempDir("", "ghostunnel-test")
	panicOnError(err)

	tmpFile, err := ioutil.TempFile(tmpDir, "")
	panicOnError(err)

	tmpFile.WriteString("test")
	tmpFile.Sync()
	defer os.Remove(tmpFile.Name())

	// Start watching
	watcher := make(chan bool, 1)

	go watchFiles([]string{tmpFile.Name()}, time.Duration(100)*time.Millisecond, watcher)

	time.Sleep(time.Duration(1) * time.Second)

	// Must detect new writes
	tmpFile.WriteString("new")
	tmpFile.Sync()
	tmpFile.Close()

	select {
	case _ = <-watcher:
	case _ = <-time.Tick(time.Duration(1) * time.Second):
		t.Fatalf("timeout, no notification on changed file")
	}

	// Must detect file being replaced
	os.Remove(tmpFile.Name())
	tmpFile, err = os.Create(tmpFile.Name())
	panicOnError(err)

	tmpFile.WriteString("blubb")
	tmpFile.Sync()
	tmpFile.Close()

	select {
	case _ = <-watcher:
	case _ = <-time.Tick(time.Duration(1) * time.Second):
		t.Fatalf("timeout, no notification on changed file")
	}
}

func TestHashFilesNonExistent(t *testing.T) {
	res := hashFiles([]string{"./does-not-exist"})
	if len(res) > 0 {
		t.Error("hash files generated hash for non-existent file")
	}
}

func TestFileChangedNonExistent(t *testing.T) {
	if fileChanged(map[string][32]byte{}, "./does-not-exist") {
		t.Error("hash files generated hash for non-existent file")
	}
}
