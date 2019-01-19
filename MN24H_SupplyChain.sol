pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

// author: nclinh@miennam24h.vn
contract MN24H_SupplyChain{
    
    address private _owner;
    
    struct NhaCungCap{
        address MaNcc;
        string TenNcc;
        string DiaChiNcc;
    }
    
    struct NhaPhanPhoi{
        address MaNpp;
        string TenNpp;
        string DiaChiNpp;
    }
    
    struct HangHoa{
        bytes32 MaHangHoa;
        string TenHangHoa;
        string DonVi;
        uint256 NgaySanXuat;
        uint256 NgayHetHan;
        uint256 SoLuong;
    }
    
    struct ThongKeHangHoa{
        address Holder;
        uint256 SoLuong;
    }
    
    NhaCungCap[]  private ListNcc;
    NhaPhanPhoi[] private ListNpp;
    mapping(address => HangHoa[]) private KhoHangOfNcc;
    mapping(address => HangHoa[]) private KhoHangOfNpp;
    mapping(bytes32 => ThongKeHangHoa[]) private Reports;
    
    event IssueHangHoa(bytes32 MaHangHoa, string Code, address _issuer, address _receiver, uint256 _amount);
    
    modifier onlyOwner(){
        require(msg.sender == _owner,"Require only owner constract");
        _;
    }
   
    constructor() public{
        _owner = msg.sender;
    }
    
    function _validateNccValidation(address _code) constant internal returns(bool){
         for(uint i = 0; i < ListNcc.length; i++){
            NhaCungCap memory currentNcc  = ListNcc[i];
            if(currentNcc.MaNcc == _code ){
                return true;
            }
        }
        return false;
    }

    function _validateNppValidation(address _code) constant internal returns(bool){
         for(uint i = 0; i < ListNpp.length; i++){
            NhaPhanPhoi memory currentNpp  = ListNpp[i];
            if(currentNpp.MaNpp == _code ){
                return true;
            }
        }
        return false;
    }
    
    
    function IsNppIsExists(bytes32 _masp, address _addressNpp) constant internal returns(bool){
         for(uint256 k = 0; k < Reports[_masp].length; k++){
              if(Reports[_masp][k].Holder == _addressNpp){
                  return true;
              }
         }
         return false;
    }
    
    function registerNhaCungCap(address _MaNcc, string _TenNcc, string _DiaChiNpp) public onlyOwner returns(bool){
        if(_validateNccValidation(_MaNcc))
            return false;
        
        NhaCungCap memory newNcc = NhaCungCap({
            MaNcc:  _MaNcc,
            TenNcc: _TenNcc,
            DiaChiNcc: _DiaChiNpp
        });
        
        ListNcc.push(newNcc) ;
        
        return true;
    }
    
    
    function registerNhaPhanPhoi( string _TenNpp, string _DiaChiNpp) public  returns(bool){
        if(_validateNppValidation(msg.sender))
            return false;
        
        NhaPhanPhoi memory newNpp = NhaPhanPhoi({
            MaNpp:  msg.sender,
            TenNpp: _TenNpp,
            DiaChiNpp: _DiaChiNpp
        });
        
        ListNpp.push(newNpp) ;
        
        return true;
    }
    
    function issueHangHoa(bytes32 _mahh, string _tenhh, string _donvi, uint256 _soluong, uint256 _ngaysanxuat, uint256 _ngayhethan)
         public returns(bool){
             
        if(!_validateNccValidation(msg.sender))
            return false;
    
         HangHoa memory newHanghoa = HangHoa({
            MaHangHoa:  _mahh,
            TenHangHoa: _tenhh,
            DonVi: _donvi,
            NgayHetHan: _ngayhethan, 
            NgaySanXuat: _ngaysanxuat,
            SoLuong: _soluong
        });
        
        KhoHangOfNcc[msg.sender].push(newHanghoa);
        
        ThongKeHangHoa memory report =  ThongKeHangHoa({
            Holder: msg.sender,
            SoLuong: newHanghoa.SoLuong
        });
        
        Reports[newHanghoa.MaHangHoa].push(report);
        
        emit IssueHangHoa(newHanghoa.MaHangHoa,"ISSUE", msg.sender, msg.sender, newHanghoa.SoLuong);
        
        return true;
    }
    
    
    function DeIncreaseReport(bytes32 _masp, address _holder, uint256 _amount) internal{
         for(uint256 k = 0; k < Reports[_masp].length; k++){
              if(Reports[_masp][k].Holder == _holder){
                  Reports[_masp][k].SoLuong -= _amount;
                  break;
              }
        }
    }
    
    function IncreaseReport(bytes32 _masp, address _holder, uint256 _amount) internal{
        bool falg = IsNppIsExists(_masp,_holder );
        if(falg){
            for(uint256 k = 0; k < Reports[_masp].length; k++){
                if(Reports[_masp][k].Holder == _holder){
                    Reports[_masp][k].SoLuong += _amount;
                    break;
                }
            }
        }else{
             Reports[_masp].push(ThongKeHangHoa({
                Holder: _holder,
                SoLuong: _amount
            }));
        }
    }
    
    function getHangHoaTuNcc(address _ncc, bytes32 _masp) view public returns(HangHoa item){
        for(uint256 i = 0; i < KhoHangOfNcc[_ncc].length; i++){
            if(KhoHangOfNcc[_ncc][i].MaHangHoa == _masp ){
                item = KhoHangOfNcc[_ncc][i];
                break;
            }
        }
    }
    
    function IncreaseKhoHangNpp(address _npp,bytes32 _masp, uint256 _amount, address _ncc) internal{
        
        for(uint256 i = 0; i < KhoHangOfNpp[_npp].length; i++){
            if(KhoHangOfNpp[_npp][i].MaHangHoa == _masp ){
                KhoHangOfNpp[_npp][i].SoLuong += _amount;
                return;
            }
        }
        
        HangHoa memory spHienTai = getHangHoaTuNcc(_ncc, _masp);
        
        KhoHangOfNpp[_npp].push(HangHoa({
            MaHangHoa: spHienTai.MaHangHoa,
            TenHangHoa: spHienTai.TenHangHoa,
            DonVi: spHienTai.DonVi,
            SoLuong: _amount,
            NgaySanXuat: spHienTai.NgaySanXuat,
            NgayHetHan: spHienTai.NgayHetHan
        }));
    }
    
    // 1: Nha PP
    // 2: Nha cc
    function DeIncreaseKhoHang(address _addr,bytes32 _masp, uint256 _amount, uint256 _type) internal{
        if(_type == 1){
            for(uint256 i = 0; i < KhoHangOfNpp[_addr].length; i++){
                if(KhoHangOfNpp[_addr][i].MaHangHoa == _masp ){
                    KhoHangOfNpp[_addr][i].SoLuong -= _amount;
                    return;
                }
            }
        }else if(_type == 2){
            for( i = 0; i < KhoHangOfNcc[_addr].length; i++){
                if(KhoHangOfNcc[_addr][i].MaHangHoa == _masp ){
                    KhoHangOfNcc[_addr][i].SoLuong -= _amount;
                    return;
                }
            }
        }
    }
    
    function XuatKhoToNpp(address _addressNpp, bytes32 _masp, uint256 _amount) public returns(bool){
        if(!_validateNccValidation(msg.sender))
            return false;
        
        HangHoa memory spHienTai = getHangHoaTuNcc(msg.sender, _masp);
        
        if(spHienTai.SoLuong < _amount)
            return false;
            
        IncreaseKhoHangNpp(_addressNpp, _masp, _amount, msg.sender);
        DeIncreaseKhoHang(msg.sender,_masp, _amount, 2);
        DeIncreaseReport(spHienTai.MaHangHoa, msg.sender, _amount);
        IncreaseReport(spHienTai.MaHangHoa,_addressNpp, _amount );
        emit IssueHangHoa(spHienTai.MaHangHoa,"XUATKHO_TO_NPP", msg.sender, _addressNpp, _amount);
        
        return true;
    }
    
    
    // Người hiện giao dịch
    // Xuất ra từ người quản lý hàng hóa
    function SellHangHoa(bytes32 _masp, uint256 _amount) public returns(bool){
        
        HangHoa memory spHienTai;
        
        for(uint256 i = 0; i < KhoHangOfNpp[msg.sender].length; i++){
            if(KhoHangOfNpp[msg.sender][i].MaHangHoa == _masp ){
                spHienTai = KhoHangOfNpp[msg.sender][i];
                break;
            }
        }
        
        if(spHienTai.SoLuong < _amount)
            return false;
    
        DeIncreaseKhoHang(msg.sender,_masp, _amount, 1);
        DeIncreaseReport(spHienTai.MaHangHoa, msg.sender, _amount);
        emit IssueHangHoa(spHienTai.MaHangHoa,"XUATKHO_TO_KL", msg.sender, address(0), _amount);
        return true;
    }
    
    
    function getListReportMaHang(bytes32 _masp) view public returns(ThongKeHangHoa[] rep){
        rep = Reports[_masp];
    }
    
    
    function getChitietNcc(address _addr) view public returns(string, string){
         for(uint i = 0; i < ListNcc.length; i++){
            NhaCungCap memory currentNcc  = ListNcc[i];
            if(currentNcc.MaNcc == _addr ){
                return (currentNcc.TenNcc, currentNcc.DiaChiNcc);
            }
        }
        return;
    }
    
    
    function getChitietNpp(address _addr) view public returns(string, string){
         for(uint i = 0; i < ListNpp.length; i++){
            NhaPhanPhoi memory currentNpp  = ListNpp[i];
            if(currentNpp.MaNpp == _addr ){
                return (currentNpp.TenNpp, currentNpp.DiaChiNpp);
            }
        }
        return;
    }
    
    
    function getKhoHangNcc(address _addr) view public returns(HangHoa[]){
        return KhoHangOfNcc[_addr];
    }
    
    function getKhoHangNpp(address _addr) view public returns(HangHoa[]){
        return KhoHangOfNpp[_addr];
    }
    
    
    
}
