<?php

declare(strict_types=1);

namespace App\Modules\Auth\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPasswordNotification extends Notification
{
    use Queueable;

    public function __construct(private readonly string $token) {}

    /**
     * @return list<string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $email = method_exists($notifiable, 'getEmailForPasswordReset')
            ? $notifiable->getEmailForPasswordReset()
            : $notifiable->email;

        $url = rtrim((string) config('vcos.frontend_url'), '/')
            .'/reset-password?token='.urlencode($this->token)
            .'&email='.urlencode($email);

        $locale = $notifiable->locale ?? app()->getLocale();

        if ($locale === 'fa') {
            return (new MailMessage)
                ->subject('بازیابی رمز عبور')
                ->line('برای تنظیم رمز جدید روی دکمه زیر بزنید. اگر شما این درخواست را نداده‌اید، این نامه را نادیده بگیرید.')
                ->action('تنظیم رمز جدید', $url)
                ->line('این پیوند پس از مدتی منقضی می‌شود.');
        }

        return (new MailMessage)
            ->subject('Reset your password')
            ->line('Use the button below to choose a new password. If you did not ask for this, you can ignore the email.')
            ->action('Choose a new password', $url)
            ->line('This link will expire shortly.');
    }
}
