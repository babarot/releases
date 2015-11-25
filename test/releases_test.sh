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
    it "L=peco/peco"
      L=peco/peco main >/dev/null
      assert equal $? $true
    end
    it "L=junegunn/fzf-bin"
      L=junegunn/fzf-bin main >/dev/null
      assert equal $? $true
    end
    it "L=b4b4r07/gotcha"
      L=b4b4r07/gotcha main >/dev/null
      assert equal $? $true
    end
    it "os detection b4b4r07/gomi"
      L=b4b4r07/gomi main os >/dev/null
      assert equal $? $true
    end
    it "os detection stedolan/jq"
      L=stedolan/jq main os >/dev/null
      assert equal $? $true
    end
  end
end
