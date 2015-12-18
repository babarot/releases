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

  describe "specifying version"
    it "downloads release 0.11.0 of junegunn/fzf-bin"
      L=junegunn/fzf-bin V=0.11.0 main >/dev/null
      assert file_present 'fzf-0.11.0-*'
    end

    it "downloads tag jq 1.5 rc1"
      L=stedolan/jq V=jq-1.5rc1 main >/dev/null
      assert file_present 'jq-1.5rc1*'
    end

    it "fails when an invalid version is specified"
      # Use subshell because this dies
      ( L=junegunn/fzf-bin V=foobar main >/dev/null 2>&1 )
      assert unequal $? $true
    end
  end
end
