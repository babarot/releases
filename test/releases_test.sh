#!/bin/bash

# definition
fzf() { :; }

true=0
false=1

DEBUG=1
. ./releases

describe "releases"
  describe "unit test"
    it "has"
      has "fzf"
      assert equal $? $true
    end
    it "cleanup"
      touch a.zip b.tar.gz c.tgz
      cleanup
      [ ! -f a.zip ] && [ ! -f b.tar.gz ] && [ ! -f c.tgz ]
      assert equal $? $true
    end
  end

  describe "integration test"
    it "main"
      L=peco/peco main >/dev/null
      assert equal $? $true
    end
  end
end
