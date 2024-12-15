// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// Import the ERC20 interface and Ownable
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//@title — Curso ETH KIPU - SimpleDEX Contract
//@author — Manuel Hidalgo
contract SimpleDEX is Ownable{
    IERC20 public tokenA;
    IERC20 public tokenB;

    //@dev Event emitted when the liquidity is added
    event LiquidityAdded(uint256 amountA, uint256 amountB);
    //@dev Event emitted when the liquidity is removed
    event LiquidityRemoved(uint256 amountA, uint256 amountB);
    //@dev Event emitted when a token is swapped
    event TokenSwappedA(address indexed user, uint256 amountIn, uint256 amountOut);
    event TokenSwappedB(address indexed user, uint256 amountIn, uint256 amountOut);

    constructor(address _tokenA, address _tokenB) Ownable (msg.sender) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    //@dev Deposit tokens into the liquidity pool
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner{
        require(amountA > 0 && amountB > 0, "Invalid amounts");

        //@dev Transfer tokens to the contract
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        //@dev Event emitted due to liquidity added
        emit LiquidityAdded(amountA, amountB);

    }

    //@dev Withdraw tokens from the liquidity pool
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner{
        require(amountA <= tokenA.balanceOf(address(this)) && amountB <= tokenB.balanceOf(address(this)), "Insufficient liquidity");

        //@dev Transfer tokens back to the user
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        //@dev Event emitted due to liquidity removed
        emit LiquidityRemoved(amountA, amountB);

    }

    //@dev Swap function - swap tokenAfor tokenB
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Invalid input amount");

        uint256 amountBOut = getAmountOut(amountAIn, tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this)));

        //@dev Transfer Token A from the user to the contract
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        
        //@dev Transfer Token B to the user
        tokenB.transfer(msg.sender, amountBOut);

        emit TokenSwappedA(msg.sender, amountAIn, amountBOut);
    }

    //@dev Swap function - swap tokenB for tokenA
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Invalid input amount");

        uint256 amountAOut = getAmountOut(amountBIn, tokenB.balanceOf(address(this)), tokenA.balanceOf(address(this)));

        //@dev Transfer Token B from the user to the contract
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        
        //@dev Transfer Token B to the user
        tokenA.transfer(msg.sender, amountAOut);

        emit TokenSwappedB(msg.sender, amountBIn, amountAOut);
    }
    

    //@dev Get price token
    function getPrice(address _token) external view returns (uint256) {
        require(_token == address(tokenA) || _token == address(tokenB), "invalid token");

        return _token == address(tokenA)
        ? (tokenB.balanceOf(address(this)) * 1e18) / tokenA.balanceOf(address(this))
        : (tokenA.balanceOf(address(this)) * 1e18) / tokenB.balanceOf(address(this));
    }

    
    //@dev Get output amount for a swap
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) private pure returns (uint256) {
    
        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn + amountIn;

        return numerator / denominator;
    }


}
