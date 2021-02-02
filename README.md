# freebsdPostInstall

    Usage
    # ./freebsdPostInstall.sh
    or
    # ./freebsdPostInstall.sh -u username -n "Real Name" -p password [-w]


# このスクリプトは

FreeBSD をインストールした後、設定を自動的に行います。

## 具体的には

1. freebsd-update で、システムを最新にします。
2. portsnap で、portsを最新にします。
3. /etc/rc.conf などの設定ファイルを修正します。
4. ports_list.txt に記載したアプリケーションを、pkgを用いてインストールします。
5. （必要に応じて）ユーザーを登録します。
6. このスクリプトを走らせて、再起動したらDesktop環境が整っていることを目指しています。
