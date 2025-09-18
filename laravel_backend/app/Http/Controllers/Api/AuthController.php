<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Auth\LoginRequest;
use App\Http\Requests\Api\Auth\RegisterRequest;
use App\Http\Requests\Api\Auth\ForgotPasswordRequest;
use App\Http\Requests\Api\Auth\ResetPasswordRequest;
use App\Http\Requests\Api\Auth\VerifyEmailRequest;
use App\Http\Requests\Api\Auth\VerifyPhoneRequest;
use App\Http\Requests\Api\Auth\RefreshTokenRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\AuthService;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    protected $authService;
    protected $notificationService;

    public function __construct(AuthService $authService, NotificationService $notificationService)
    {
        $this->authService = $authService;
        $this->notificationService = $notificationService;
    }

    /**
     * User login
     */
    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $credentials = $request->validated();
            
            $user = $this->authService->authenticate($credentials);
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid credentials',
                ], 401);
            }

            $token = $user->createToken('auth_token')->plainTextToken;
            $refreshToken = $this->authService->createRefreshToken($user);

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'data' => [
                    'token' => $token,
                    'refresh_token' => $refreshToken,
                    'user' => new UserResource($user),
                    'expires_at' => now()->addMinutes(config('sanctum.expiration')),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Login failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * User registration
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        try {
            $userData = $request->validated();
            
            $user = $this->authService->register($userData);
            
            // Send verification email
            $this->notificationService->sendEmailVerification($user);
            
            $token = $user->createToken('auth_token')->plainTextToken;
            $refreshToken = $this->authService->createRefreshToken($user);

            return response()->json([
                'success' => true,
                'message' => 'Registration successful. Please verify your email.',
                'data' => [
                    'token' => $token,
                    'refresh_token' => $refreshToken,
                    'user' => new UserResource($user),
                    'expires_at' => now()->addMinutes(config('sanctum.expiration')),
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Registration failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Refresh token
     */
    public function refreshToken(RefreshTokenRequest $request): JsonResponse
    {
        try {
            $refreshToken = $request->validated()['refresh_token'];
            
            $user = $this->authService->refreshToken($refreshToken);
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid refresh token',
                ], 401);
            }

            $token = $user->createToken('auth_token')->plainTextToken;
            $newRefreshToken = $this->authService->createRefreshToken($user);

            return response()->json([
                'success' => true,
                'message' => 'Token refreshed successfully',
                'data' => [
                    'token' => $token,
                    'refresh_token' => $newRefreshToken,
                    'user' => new UserResource($user),
                    'expires_at' => now()->addMinutes(config('sanctum.expiration')),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token refresh failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * User logout
     */
    public function logout(Request $request): JsonResponse
    {
        try {
            $request->user()->currentAccessToken()->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Logout successful',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Logout failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Forgot password
     */
    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        try {
            $email = $request->validated()['email'];
            
            $status = Password::sendResetLink(['email' => $email]);
            
            if ($status === Password::RESET_LINK_SENT) {
                return response()->json([
                    'success' => true,
                    'message' => 'Password reset link sent to your email',
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Unable to send reset link',
            ], 400);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to send reset link: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Reset password
     */
    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        try {
            $credentials = $request->validated();
            
            $status = Password::reset(
                $credentials,
                function ($user, $password) {
                    $user->forceFill([
                        'password' => Hash::make($password),
                    ])->save();
                }
            );

            if ($status === Password::PASSWORD_RESET) {
                return response()->json([
                    'success' => true,
                    'message' => 'Password reset successful',
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Password reset failed',
            ], 400);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Password reset failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Verify email
     */
    public function verifyEmail(VerifyEmailRequest $request): JsonResponse
    {
        try {
            $token = $request->validated()['token'];
            
            $user = User::where('email_verification_token', $token)->first();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid verification token',
                ], 400);
            }

            $user->update([
                'email_verified_at' => now(),
                'email_verification_token' => null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Email verified successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Email verification failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Verify phone
     */
    public function verifyPhone(VerifyPhoneRequest $request): JsonResponse
    {
        try {
            $phone = $request->validated()['phone'];
            $code = $request->validated()['code'];
            
            $user = User::where('phone', $phone)
                ->where('phone_verification_code', $code)
                ->first();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid verification code',
                ], 400);
            }

            $user->update([
                'phone_verified_at' => now(),
                'phone_verification_code' => null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Phone verified successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Phone verification failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get current user
     */
    public function me(Request $request): JsonResponse
    {
        try {
            return response()->json([
                'success' => true,
                'data' => new UserResource($request->user()),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get user data: ' . $e->getMessage(),
            ], 500);
        }
    }
}
