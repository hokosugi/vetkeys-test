import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";

let text: Text = "Hello, World!";
let nat8Array: [Nat8] = Text.encodeUtf8(text); // まずNat8配列を取得
let blob: Blob = Blob.fromArray(nat8Array); // nat8ArrayをBlobに変換