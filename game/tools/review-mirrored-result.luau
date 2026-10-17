local result=game:GetAttribute("BVSMirrorResult")
return {pairs=game:GetAttribute("BVSMirrorPairs"),error=game:GetAttribute("BVSMirrorError"),result=if result then game:GetService("HttpService"):JSONDecode(result) else nil}
