import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Hex "./utils/Hex";
import Debug "mo:base/Debug";

actor {
    type VETKD_SYSTEM_API = actor {
        vetkd_public_key : ({
            canister_id : ?Principal;
            derivation_path : [Blob];
            key_id : { curve : { #bls12_381 }; name : Text };
        }) -> async ({ public_key : Blob });
        vetkd_encrypted_key : ({
            public_key_derivation_path : [Blob];
            derivation_id : Blob;
            key_id : { curve : { #bls12_381 }; name : Text };
            encryption_public_key : Blob;
        }) -> async ({ encrypted_key : Blob });
    };
    let vetkd_system_api : VETKD_SYSTEM_API = actor ("s55qq-oqaaa-aaaaa-aaakq-cai");

    // グループ管理用の型とストレージを追加
    private type GroupId = Text;
    private type UserId = Principal;
    private type Permission = {
        #Owner;
        #Editor;
        #Viewer;
    };
    
    // グループ情報を保存する安定変数
    private stable var groups = Map.HashMap<GroupId, {
        owner: UserId;
        members: Map.HashMap<UserId, Permission>;
    }>(0, Text.equal, Text.hash);

    // グループ管理関数
    public shared({ caller }) func createGroup(groupId: GroupId) : async Bool {
        let newGroup = {
            owner = caller;
            members = Map.HashMap<UserId, Permission>(0, Principal.equal, Principal.hash);
        };
        groups.put(groupId, newGroup);
        return true;
    };

    public shared({ caller }) func addMemberToGroup(groupId: GroupId, member: UserId, permission: Permission) : async Bool {
        switch(groups.get(groupId)) {
            case null { return false; };
            case (?group) {
                if (group.owner == caller) {
                    group.members.put(member, permission);
                    return true;
                };
                return false;
            };
        };
    };

    // encrypted_ibe_decryption_key_for_caller を修正
    public shared ({ caller }) func encrypted_ibe_decryption_key_for_caller(
        groupId: GroupId,
        encryption_public_key : Blob
    ) : async Text {
        switch(groups.get(groupId)) {
            case null { return ""; };
            case (?group) {
                // グループメンバーのPrincipalを結合してderivation_idを生成
                var memberPrincipals = Buffer.Buffer<Principal>(0);
                for ((member, permission) in group.members.entries()) {
                    memberPrincipals.add(member);
                };
                
                let derivation_id = Principal.toBlob(Principal.fromText(
                    Text.join("", Iter.map<Principal, Text>(
                        memberPrincipals.vals(),
                        func(p: Principal) : Text = Principal.toText(p)
                    ))
                ));

                let { encrypted_key } = await vetkd_system_api.vetkd_encrypted_key({
                    derivation_id;
                    public_key_derivation_path = Array.make(Text.encodeUtf8("ibe_encryption"));
                    key_id = { curve = #bls12_381; name = "test_key_1" };
                    encryption_public_key;
                });
                
                Hex.encode(Blob.toArray(encrypted_key));
            };
        };
    };
};


/*
actor {

    public shared ({ caller = _ }) func app_vetkd_public_key(derivation_path : [Blob]) : async Text {
        let { public_key } = await vetkd_system_api.vetkd_public_key({
            canister_id = null;
            derivation_path;
            key_id = { curve = #bls12_381; name = "test_key_1" };
        });
        Hex.encode(Blob.toArray(public_key));
    };

    public shared ({ caller = _ }) func symmetric_key_verification_key() : async Text {
        let { public_key } = await vetkd_system_api.vetkd_public_key({
            canister_id = null;
            derivation_path = Array.make(Text.encodeUtf8("symmetric_key"));
            key_id = { curve = #bls12_381; name = "test_key_1" };
        });
        Hex.encode(Blob.toArray(public_key));
    };

    public shared ({ caller }) func encrypted_symmetric_key_for_caller(encryption_public_key : Blob) : async Text {
        Debug.print("encrypted_symmetric_key_for_caller: caller: " # debug_show (caller));

        let { encrypted_key } = await vetkd_system_api.vetkd_encrypted_key({
            derivation_id = Principal.toBlob(caller);
            public_key_derivation_path = Array.make(Text.encodeUtf8("symmetric_key"));
            key_id = { curve = #bls12_381; name = "test_key_1" };
            encryption_public_key;
        });
        Hex.encode(Blob.toArray(encrypted_key));
    };

    public shared ({ caller = _ }) func ibe_encryption_key() : async Text {
        let { public_key } = await vetkd_system_api.vetkd_public_key({
            canister_id = null;
            derivation_path = Array.make(Text.encodeUtf8("ibe_encryption"));
            key_id = { curve = #bls12_381; name = "test_key_1" };
        });
        Hex.encode(Blob.toArray(public_key));
    };

// グループでencrypted_keyを作成するには引数(encryption_public_key)を配列(encryption_public_keys)にする
// encrypted_keyはローカルに保存？
    public shared ({ caller }) func encrypted_ibe_decryption_key_for_caller(encryption_public_key : Blob) : async Text {
        Debug.print("encrypted_ibe_decryption_key_for_caller: caller: " # debug_show (caller));

        // グループの場合はderivation_idをPrincipalの複合体にする必要あり？
        let { encrypted_key } = await vetkd_system_api.<!-- グループ管理セクション -->
<div id="group_management">
    <h2>Group Management</h2>
    <form id="create_group_form">
        <input type="text" id="group_id" placeholder="Group ID">
        <button type="submit">Create Group</button>
    </form>

    <form id="add_member_form">
        <input type="text" id="member_principal" placeholder="Member Principal">
        <select id="permission">
            <option value="Owner">Owner</option>
            <option value="Editor">Editor</option>
            <option value="Viewer">Viewer</option>
        </select>
        <button type="submit">Add Member</button>
    </form>
</div>

<!-- 既存の暗号化/復号化フォーム -->
<div id="encryption_section">
    <!-- 既存のフォームは維持 -->
</div>vetkd_encrypted_key({
            derivation_id = Principal.toBlob(caller);
        // これでderivation path毎に別目的の鍵を生成する
            public_key_derivation_path = Array.make(Text.encodeUtf8("ibe_encryption"));
            key_id = { curve = #bls12_381; name = "test_key_1" };
            encryption_public_key;
        });
        Hex.encode(Blob.toArray(encrypted_key));
    };
};

*/