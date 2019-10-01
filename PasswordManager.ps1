$folder_path = $PSScriptRoot
$card_file = $folder_path + "\card_json"

class CardHolder {
    [Collections.ArrayList] $cards

    CardHolder() {
        $this.cards = New-Object System.Collections.ArrayList
    }

    [void] add($card) {
        $this.cards.Add($card) 
        return
    }

    [void] show_list() {
        if ($this.cards.count -eq 0) {
            [console]::WriteLine("CardHolder is Empty")
            return
        }

        $list = @()
        $list += ,@('ID', 'Caption', 'Username')
        $out = ''
        foreach($card in $this.cards) {
            $out = [string]$card.id + ":`t" + $card.caption
            [console]::WriteLine($out)
        }
        return
    }

    [int] find_card_by_id([int] $id) {
        $i = 0
        foreach($card in $this.cards) {
            if ($card.id -eq $id) {
                return $i
            }
            $i += 1
        }
        [console]::WriteLine("Not found such id.")
        return -1
    }

    [int] next_card_id() {
        if ($this.cards.count -eq 0) {
            return 1
        }

        $next_id = $this.cards[$this.cards.count - 1].id + 1
        return $next_id
    }

    [void] copy_user([int] $id) {
        $index = $this.find_card_by_id($id)
        if ($index -eq -1) {
            return
        }
        $capname = $this.cards[$index].caption
        $this.cards[$index].username | Set-Clipboard
        $out = $capname + " username is Set-Clipboarded."
        [console]::WriteLine($out)
    }

    [void] copy_pass([int] $id) {
        $index = $this.find_card_by_id($id)
        if ($index -eq -1) {
            return
        }
        $capname = $this.cards[$index].caption
        $this.cards[$index].password | Set-Clipboard
        $out = $capname + " password is Set-Clipboarded."
        [console]::WriteLine($out)
    }

    [void] add_card([int] $id, [string] $capname, [string] $username, [string] $password) {
        $new_card = New-Object Card($id, $capname, $username, $password)
        $this.add($new_card)
        $out = $capname + " card is added."
        [console]::WriteLine($out)
    }

    [void] remove_card([int] $id) {
        if ($this.find_card_by_id($id) -eq -1) {
            return
        }
        $capname = $this.cards[$id - 1].caption
        $this.cards.RemoveAt($id - 1)
        $out = $capname + " card is removed."
        [console]::WriteLine($out)
    }

    [void] update_caption([int] $id, [string] $caption) {
        if ($this.find_card_by_id($id) -eq -1) {
            return
        }
        $this.cards[$id - 1].caption = $caption
        $out = $this.cards[$id - 1].caption + " caption is updated."
        [console]::WriteLine($out)
    }

    [void] update_password([int] $id, [string] $password) {
        if ($this.find_card_by_id($id) -eq -1) {
            return
        }
        $this.cards[$id - 1].password = $password
        $out = $this.cards[$id - 1].caption + " pass is updated."
        [console]::WriteLine($out)
    }

    [void] update_username([int] $id, [string] $username) {
        if ($this.find_card_by_id($id) -eq -1) {
            return
        }
        $this.cards[$id - 1].username  = $username
        $out = $this.cards[$id - 1].caption + " user is updated."
        [console]::WriteLine($out)
    }
}

class Card {
    [int] $id
    [string] $caption
    [string] $username
    [string] $password

    Card([int] $id, [string] $caption, [string] $username, [string] $password) {
        $this.id = $id
        $this.caption = $caption
        $this.username = $username
        $this.password = $password
    }

    [int] get_id() {
        return $this.id
    }

    [string] get_caption() {
        return $this.caption
    }

    [string] get_username() {
        return $this.username
    }

    [string] get_password() {
        return $this.password
    }
}

class AESCipher {
    [byte[]] $secret_key

    AESCipher() {}

    [string] secure_string_to_plain($secure_string) {
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure_string)
        $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

        return $plain
    }

    [string] padding($key) {
        # aes key length is defined 256bit
        # padding key 
        if ($key.length -lt 32) {
            $key = $key + "K" * (32 - $key.length)
        }elseif ($key.length -gt 32) {
            $key = $key.SubString(0, 32)
        }
        return $key
    }

    [void] input_secret_key() {
        $input_string = Read-Host -Prompt "Enter your secret key" -AsSecureString
        $input_plain = $this.secure_string_to_plain($input_string)

        $enc = [System.Text.Encoding]::UTF8
        $padded_key = $this.padding($input_plain)
        $key = $enc.GetBytes($padded_key)
        $this.secret_key = $key
    }

    [string] encrypt ($plain) {
        # plainpassword to securestring
        $secure_string = ConvertTo-SecureString -String $plain -AsPlaintext -Force

        # securestring to encrypted text
        $cipher = ConvertFrom-SecureString -SecureString $secure_string -key $this.secret_key

        return $cipher
    }

    [string] decrypt ($cipher) {
        # cipher text to secure string
        $secure_string = ConvertTo-SecureString $cipher -key $this.secret_key 

        # secure string to plain text
        $plain = $this.secure_string_to_plain($secure_string)

        return $plain
    }
}

function Welcome() {
    Write-Host "                                                                      " -ForegroundColor "Green";
    Write-Host " _____                             _    _____                         " -ForegroundColor "Green";
    Write-Host "|  _  |___ ___ ___ _ _ _ ___ ___ _| |  |     |___ ___ ___ ___ ___ ___ " -ForegroundColor "Green";
    Write-Host "|   __| .'|_ -|_ -| | | | . |  _| . |  | | | | .'|   | .'| . | -_|  _|" -ForegroundColor "Green";
    Write-Host "|__|  |__,|___|___|_____|___|_| |___|  |_|_|_|__,|_|_|__,|_  |___|_|  " -ForegroundColor "Green";
    Write-Host "                                              Good Luck!!|___|        " -ForegroundColor "Green";
}

function help() {
    echo "                                                                                              "
    echo "help                                      : Display this help text."
    echo "show list/ls                              : Display saved card ids and captions."
    echo "copy <user/pass> <id>                     : Copy to Set-Clipboardboard selected id's user/pass."
    echo "cp <id>                                   : Copy to Set-Clipboardboard selected id's pass."
    echo "cu <id>                                   : Copy to Set-Clipboardboard selected id's user."
    echo "update <caption/user/pass> <id> <value>   : Update saved card caption/user/pass to value"
    echo "add <caption> <user> <pass>               : Add card."
    echo "remove <id>                               : Remove card by selected id."
    echo "changepass                                : Change current secret password. Save command is needed to save changed password."
    echo "save                                      : Save changes"
    echo "exit                                      : Exit program"
    echo "                                                                                              "
}

function main() {
    welcome

    # card list decrypt
    if (Test-Path $card_file)  {
        $cipher = Get-Content $card_file
        $aes_cipher = New-Object AESCipher
        for($i = 0; $i -lt 3; $i++){
            try{
                $aes_cipher.input_secret_key()
                $plain = $aes_cipher.decrypt($cipher)
                break
            }catch [Exception]{
                Write-Host "Wrong key." -ForegroundColor "red"
            }
            if ($i -eq 2) {
                exit
            }
        }
    } else {
        [Console]::WriteLine("Set your secret key.")
        $aes_cipher = New-Object AESCipher
        $aes_cipher.input_secret_key()
        $plain = ""
    }

    # card into card holder
    $card_holder = New-Object CardHolder
    $card_list = $plain | convertfrom-json
    foreach($card_hash in $card_list.cards) {
        $card = New-Object Card($card_hash.id, $card_hash.caption, $card_hash.username, $card_hash.password)
        $card_holder.add($card)
    }

    # command input loop
    while($true) {
        $input_string = Read-Host -Prompt ">" 
        $splited_input = $input_string.Split(" ")
        switch ($splited_input[0]) {
            "show" {
                switch ($splited_input[1]) {
                    "list" {
                        $card_holder.show_list()
                    }
                }
            }
            "ls" {
                $card_holder.show_list()
            }
            "copy" {
                switch ($splited_input[1]) {
                    "pass" {
                        $card_holder.copy_pass([int]$splited_input[2])
                    }
                    "user" {
                        $card_holder.copy_user([int]$splited_input[2])
                    }
                }
            }
            "cp" {
                $card_holder.copy_pass([int]$splited_input[1])
            }
            "cu" {
                $card_holder.copy_user([int]$splited_input[1])
            }
            "add" {
                $card_holder.add_card($card_holder.next_card_id(), $splited_input[1], $splited_input[2], $splited_input[3])
            }
            "remove" {
                $card_holder.remove_card($splited_input[1])
            }
            "update" {
                switch ($splited_input[1]) {
                    "caption" {
                        $card_holder.update_caption([int]$splited_input[2], $splited_input[3])
                    }
                    "pass" {
                        $card_holder.update_password([int]$splited_input[2], $splited_input[3])
                    }
                    "user" {
                        $card_holder.update_username([int]$splited_input[2], $splited_input[3])
                    }
                }
            }
            "save" {
                # Backup card file.
                if (Test-Path $card_file) {
                    cp $card_file "${folder_path}card_json.backup"
                }
                $json = $card_holder | ConvertTo-Json
                $aes_cipher.encrypt($json) | Out-File -FilePath "${folder_path}/card_json" -Force
                $out = "Current card info is saved."
                [console]::WriteLine($out)
            }
            "changepass" {
                $aes_cipher.input_secret_key()
            }
            "help" {
                help
            }
            "exit" {
                exit
            }
        }
    }
}

main
