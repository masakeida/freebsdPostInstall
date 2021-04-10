# freebsdPostInstall

## Usage

    # ./freebsdPostInstall.sh
    or
    # ./freebsdPostInstall.sh -u username -n "Real Name" -p password [-w]

    Usage:
        freebsdPostInstall.sh [<options>]
    Options:
        --version, -v     print freebsdPostInstall.sh version
        --user, -u        set new user
        --gecos, -n       set new user's name for GECOS field
        --passwd, -p      set new user's password
        --vmware, -w      configure for vmware

## このスクリプトは

FreeBSD をインストールした後、設定を自動的に行います。

### 具体的には

1. freebsd-update で、システムを最新にします。
1. portsnap で、portsを最新にします。
1. /etc/rc.conf などの設定ファイルを修正します。
1. ports_list.txt に記載したアプリケーションを、pkgを用いてインストールします。
1. （必要に応じて）ユーザーを登録します。
1. インストール後、このスクリプトを走らせて、再起動したらDesktop環境が整っていることを目指しています。
